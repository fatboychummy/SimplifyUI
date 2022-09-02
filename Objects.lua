local expect = require "cc.expect".expect

local UDim, UDim2 = require "UDim", require "UDim2"

local Objects = {}

local function dcopy(t)
  local t_ = {}
  
  for k, v in pairs(t) do
    if type(v) == "table" then
      t_[k] = dcopy(v)
    else
      t_[k] = v
    end
  end

  return t_
end

local function copy(t)
  local t_ = {}

  for k, v in pairs(t) do
    t_[k] = v
  end

  return t_
end

--- Create a new object type.
-- 
function Objects.new(property_dictionary, object_type)
  expect(1, property_dictionary, "table")
  expect(2, object_type, "string")

  local obj = dcopy(property_dictionary)

  obj._Children = {}
  obj._IsObject = true
  obj._Type = object_type
  obj.Position = UDim2.new()
  obj.DrawOrder = 0
  obj.Enabled = true
  obj.Events = {} -- [[ {eventname = {id=listener, id=listener, ...}} ]]

  function obj:GetChildren()
    return copy(self._Children)
  end

  function obj:AddChild(child, switch)
    if child == self then
      error("Cannot add self to children.", 2)
    end

    if not self:FindChild(child) then
      table.insert(self._Children, child)
    end
    
    if not switch then
      child.Parent = self
    end
  end

  function obj:FindChild(child)
    for i = 1, #self._Children do
      if self._Children[i] == child then
        return i
      end
    end
  end

  function obj:Redraw()
    if self._Parent then
      self._Parent:Redraw()
    else
      self:Draw()
      self:DrawChildren()
    end
  end

  function obj:Push(event, ...)
    if self.Events[event] then
      for k, v in pairs(self.Events[event]) do
        v(...)
      end
    end
  end

  function obj:PushChildren(...)
    local children = self._Children
    for i = 1, #children do
      children[i]:Push(...)
    end
  end

  return setmetatable(obj, 
    {
      __tostring = function(self)
        return string.format("Object: %s", self._Type)
      end,
      -- Index function to catch getting children and parent.
      __index = function(self, idx)
        if idx == "Parent" then
          return self._Parent
        elseif idx == "Children" then
          return self:GetChildren()
        end
      end,
      -- New index to protect the parent value and children value.
      __newindex = function(self, idx, new_val)
        if idx == "Parent" then
          local _type = type(new_val)
          if _type ~= "table" and _type ~= "nil" then
            error("Cannot set parent to a non-table value (term object or object) or nil.", 2)
          end

          local parent = rawget(self, "_Parent")

          -- Check if there is already a parent
          if parent then
            if parent._IsObject then
              -- Remove self from the parent's list of children
              local i = parent:FindChild(self)
              if i then
                table.remove(parent._Children, i)
              end
            end
          end

          -- Then set our parent to the new parent
          rawset(self, "_Parent", new_val)

          -- And check if the new parent is an object
          -- If not, it's likely just a term object.
          if _type == "table" and new_val._IsObject then
            -- and add ourself to their list of children if so.
            new_val:AddChild(self, true)
          end
        elseif idx == "Children" then
          error("Do not set the children this way. Use Object:AddChild() or change Child.Parent instead.", 2)
        end

        return nil
      end
    }
  )
end

return Objects
# What is Simplify UI?
Simplify UI aims to provide a simple library for simple graphics. Want a few
checkboxes? We got 'em. Want a few sliders? Got those too. Buttons? Yeah.

# Features

- [ ] Fully buffered
- [ ] Monitor or terminal (or multiple!) support
- [ ] Input boxes
  - [ ] Type support
- [ ] Buttons
  - [ ] Toggle
  - [ ] "Normal"
  - [ ] Timed
- [ ] Sliders
  - [ ] "Filling bar" sliders
  - [ ] "Sliding bar" sliders
  - [ ] Vertical and horizontal
  - [ ] Optional input box attachment
- [ ] Percentage bars
  - [ ] "Filling" bars
  - [ ] "Fancy Shape" bars
  - [ ] "Multi" bars
  - [ ] Higher resolution
- [ ] Checkboxes
  - [ ] Grouping
    - [ ] Radio
- [ ] Lists
  - [ ] Configurable columns and rows
- [ ] Scroll Boxes
  - [ ] Horizontal and vertical
- [ ] Shapes
  - [ ] Simple shapes
  - [ ] Make custom shapes
  - [ ] Attach objects
- [ ] Smart positioning
  - [x] Roblox UDim objects
  - [x] Roblox UDim2 objects
- [x] Objects
- [x] Core Events

## Fully buffered
The overarching system is fully buffered and updated entirely at once, to avoid
annoying flickers.

## Monitor or terminal (or multiple!) support
You will be able to select what you want to output the UI to, and it supports
outputting to any number of locations.

## Input boxes
You can create input boxes to allow the user to input information. You can also
specify a type, and the input box will not allow other types of information to
be inserted.

## Buttons
There are multiple types of buttons. The simple, "Normal" buttons which just
click once when you hit them, toggle buttons which stay enabled until you 
disable them again, and timed buttons which work similarly to minecraft's 
buttons, where they stay "active" for a certain period of time.

## Sliders
There are multiple types of sliders.

There is a filling bar slider, which looks much like a [progress bar](#Percentage-bars), but the
slider is the "percentage" filled.

[||||    ]

Also, a sliding bar styled slider, with a small line displaying the width of the
bar and a thick line in perpendicular.

--------|--------

These sliders can be horizontal or vertical, and allow for an [input box](#Input-boxes) to be
attached for finer control.

## Percentage bars
Otherwise known as "Progress bars", the percentage bars will display a
percentage in a bar-styled object.

These bars come in three styles:

- Filling
- Multi
- Fancy

Filling bars are the normal percentage bars. They simply increase an amount of
fill inside the bar based on the percentage supplied.

Multi bars allow you to supply multiple different percentages, and will display
them "stacked" on top of each-other.

Fancy bars allow you to pass a [shape](#Shapes), and it will fill it from left to
right (or bottom to top) depending on the percentage supplied.

## Checkboxes
Simple checkboxes, not much to them.

You can group them together and form radio boxes (or just group them without 
toggling them to be radio).

## Lists
You can create lists, and they can have any number of columns (widths
are automatically sized to the largest item in the list). Insert items to add a
row. A list will automatically create a vertical [Scroll box](#Scroll-boxes)
which is useful for when more items are in the list than can physically fit on
screen.

## Scroll boxes
A scroll box simply allows you to scroll through things, horizontally or
vertically. Optionally a scroll bar and scroll buttons can be positioned on the
scroll box.

## Shapes
The shape system comes with some shapes preinstalled (circles, ovals,
rectangles, etc) and allows you to attach other objects to them.

For example, to give a [percentage bar](#Percentage-bars) a border, you can
make a rectangle which is one larger in every dimension, then attach the bar in
the center of the shape.

## Smart positioning
The positioning system works in a parent-child basis. Each object can be
parented to another object, and its position is relative to that object.

We make use of Roblox's
[Udim](https://developer.roblox.com/en-us/api-reference/datatype/UDim) and
[UDim2](https://developer.roblox.com/en-us/api-reference/datatype/UDim2) objects 
for these. Everything available on the developer forum to these objects are
available in Simplify UI.

For that reason, they are not documented here.

However, some simple information about them: They are not created using the
[Object](#Objects) library here, they cannot have a parent or anything. Instead,
they are internal to some objects which require them.

## Objects
A simple object system that allows you to create your own custom objects and
attach them to other objects in this library.

All objects have the following properties and methods:

### Properties
- `obj.DrawOrder=0`
  - The order in which the object is drawn. Lower values are drawn first.
- `obj.Position=UDim2(0, 0, 0, 0)`
  - A [UDim2](https://developer.roblox.com/en-us/api-reference/datatype/UDim2)
    representing the position of the object.
- `obj.Left`, `obj.Right`, `obj.Up`, `obj.Down`
  - Defines the object that will be selected next if the user presses the
    specified arrow key. If the object is disabled, it will go to the next in
    the same direction.
- `obj.Enabled=true`
  - If true, this object and its children can be selected and will be drawn.
    Otherwise, the object cannot be selected and will not be drawn.
- `obj.Events={}`
  - [Core events](#Core-Events) that this object is subscribed to, and function
    handlers for them.
- `obj._OnFocus=thread|nil`
  - **It is recommended you do not touch this, but it is here for completion.**
  - The coroutine that is run when this object is focused.
  - Note this coroutine will be taken out of the resume pool when focus is lost,
    regardless of what event the coroutine may have been waiting for. For this
    reason it is recommended you do not do any long yielding tasks here.
  - Also note: The coroutine may be resumed without regard for what it is
    waiting on. Always check if you received an event or if you were just cold
    resumed. **This may change. I am unsure if I want this to be like this.**

### Methods
- `obj:Draw()`
  - Draws this object.
- `obj:DrawDescendants()`
  - Sort children by draw order, then call `:Draw()` and `:DrawDescendants()` on
    each.
- `obj:Redraw()`
  - Replicates `:Redraw()` to each parent until the topmost parent, at which
    point it calls `:Draw()` and `:DrawDescendants()`.
- `obj:Push(event, ...)`
  - Pushes an event to this object.
- `obj:PushDescendants(event, ...)`
  - Pushes an event to all descendants.
- `obj:GetChildren()`
  - Get the children of this object (equivalent to obj.Children).
- `obj:GetDescendants()`
  - Get all descendants of this object (children, grand-children, etc).

## Menus
A menu is a collection of objects, they are what actually run your UI system.

### Properties
- `Menu.TickRate=10`
  - Defines the maximum tickrate of this menu. This is in ticks/second.
  - Note that the result of `1/TickRate` must be divisible by 0.05, otherwise
    you may run into some issues. Some good values are `1`, `2`, `4`, `5`, `10`,
    and `20`. Numbers between `0` and `1` can be used as well, but do you really
    need it to tick that slowly?
  - Also note that it cannot be above `20`.
- `Menu.DrawSpeed=10`
  - Defines the maximum drawspeed of this menu. Same rules as `Menu.TickRate`
    apply.
- `Menu.Debug=false`
  - If enabled, a box will be displayed showing timings of all [core events](#Core-Events).
- `Menu.Focused=nil`
  - The currently focused object. **Should not be set externally.**

### Methods
- `Menu:TickDescendants()`
  - Fires the tick event to all descendants of this object. This relies on the
    fact that each object's `obj:TickChildren()` will also call
    `child:TickChildren()`.
- `Menu:Tick()`
  - Ignored if `Menu.Debug` is `false`, otherwise is used to display debug
    information.
- `Menu:SetFocus(object)`
  - Set the current focus of this menu. Control will be given to that object.

## Core Events
Each object can subscribe to events. Valid events are the following:

- `Events.PRE_DRAW`
  - This event is fired just before each frame is drawn. Use it for updating
    graphical objects.
- `Events.TICK`
  - This event is fired on every tick, defined by a [Menu](#Menus)'s tickrate.
- `Events.FOCUS_CHANGE_CONTROL_YOURS`
  - This event is fired when the focus changes to this object. Useful for
    lighting up objects or enabling terminal blink. This is called *after*
    `FOCUS_CHANGE_CONTROL_STOP`, but before coroutine control is transferred.
- `Events.FOCUS_CHANGE_CONTROL_STOP`
  - This event is fired when this object loses focus. Useful for graying-out
    objects or disabling terminal blink. This is called *before*
    `FOCUS_CHANGE_CONTROL_YOURS`, but after coroutine control is stopped.

# Debugging
To enable debugging information, set `Menu.Debug` to `true`. That will output
some useful information to the screen.

# Code samples

To be continued...
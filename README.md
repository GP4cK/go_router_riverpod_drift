# go_router_riverpod_drift

Goal of this project is to test if we have a parent screen with a list of todos (riverpod stream from the db), does it rebuild when a todo is change on a child screen.

Conclusion: Yes it does.
To reproduce:

1. Create a todo and save it. That will take you back to the home screen / todo list
2. Open the todo make a change and save it

You will stay on the edit todo screen but you will see in the console "Building HomeScreen".

One solution is to await the navigation push and refresh the provider once we come back to the screen.

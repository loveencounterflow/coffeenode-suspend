

# What?

**coffenode-suspend** is a fork of [jmar777's suspend](https://github.com/jmar777/suspend), which describes itself
as a "small, experimental library for Node that uses ES6 language features to simplify asynchronous code interactions."
All of which should be true for this version of suspend, too. See what's different:

* **coffenode-suspend** is re-written in CoffeeScript;
* it works with callback-accepting *synchronous* functions;
* this means using `suspend` (or `step`) will make your code asynchronous in case it wasn't already.
* **coffenode-suspend** will throw errors *in the generator* by default (instead of returning them);
* it will send only **a single value** (not a list with a single value) to the generator if the function calling
  back did so with a single argument (otherwise no change);
* it offers utility functions for your asynchronous chores (available as `suspend.step`, `suspend.after`, and
  `suspend.eventually`).

# How?

Head over to the [CoffyScript Readme](https://github.com/loveencounterflow/coffy-script#suspension-2) to see
some examples of `suspense` in action.


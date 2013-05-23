# suspend

`suspend` is a small, experimental library for Node.js that uses ES6 language features to simplify asynchronous code interactions.

Specifically, `suspend` exposes a minimal API around ES6 generators that is expressly designed to work seamlessly with Node.js' existing callback conventions.  This allows unobtrusive use of  `yield` execution semantics that works seamlessly with existing Node.js code bases.  `suspend` uses 100% native JavaScript - no transpiling or library-wrapping required.

## Quick Example
    
    var suspend = require('suspend');

    // simply wrap a generator in `suspend()`
    suspend(function* (resume) {
        // and yield for suspended execution, passing `resume` instead of a callback
        var data = yield require('fs').readFile(__filename, resume);
        // the result is the array of arguments passed to `resume`
        console.log(data[0].toString('utf8'));
    })();

## Why Generators (and Why `suspend`)?

[ES6 Generators](http://wiki.ecmascript.org/doku.php?id=harmony:generators) landed in V8 3.19, which means they're [available in Node.js since v0.11.2](http://blog.nodejs.org/2013/05/13/node-v0-11-2-unstable/).  Generators are awesome because, among other things, they allow for "suspended execution" semantics using the `yield` keyword ([read more on the ecmascript wiki](http://wiki.ecmascript.org/doku.php?id=harmony:generators)).

To illustrate, consider the following example:

    // note: this example is using vanilla generators - suspend makes this a lot prettier

    function* myGenerator() {
        console.log('hello');
        yield sleep(2000);
        // prints 2 seconds later
        console.log('world');
    }

    // create and initiate our iterator
    var iterator = myGenerator();
    iterator.next();

    function sleep(ms) {
        setTimeout(function() {
            iterator.next();
        }, ms);
    }

While the syntax leaves something to be desired, the 2 second pause between `console.log('hello')` and `console.log('world')` is supremely interesting.  Prior to generators, JavaScript had absolutely no language constructs to facilitate suspended execution, which is why all asynchronous operations in Node.js use callbacks.

What `suspend` does, then, is provide a small abstraction around generators that is designed to "play nice" with Node.js' existing callback conventions.  Here's the previous example modified to use `suspend`:

    suspend(function* (resume) {
        console.log('hello');
        yield sleep(2000, resume);
        // prints 2 seconds later
        console.log('world');
    })();

    function sleep(ms, cb) {
        setTimeout(cb, ms);
    }

Notice that not only is the `suspend` version much cleaner, but the `sleep()` function no longer has to know about the iterator at all.  In fact, we can remove `sleep()` altogether at this point if we want:

    suspend(function* (resume) {
        console.log('hello');
        yield setTimeout(resume, 2000);
        // prints 2 seconds later
        console.log('world');
    })();

Here's another way to think about it: `suspend` is "red light, green light" for your code execution.  `yield` means stop, and `resume` means go.

## How `suspend` Works

When you provide a generator reference to `suspend()`, it returns a new function reference that acts as an "initializer":

    var run = suspend(function* () {
        ...
    });

The generator itself is then initialized by invoking the returned function:

    run();

Assigning this initializer function to a temporary variable is, of course, necessary.  Instead, we can just invoke it immediately:

    suspend(function* () {
        ...
    })();

Invoking the generator like this is intentionally made optional, as sometimes, just like with regular functions, you don't want it to run immediately.  For example, you may want to wait for an event before beginning execution:

    someEmitter.on('some-event', suspend(function* () {
        ...
    }));

Now, given that the majority of the Node.js ecosystem uses callbacks to handle asynchronous operations, we need a way to easily interact with functions that expect a callback.  This is where `resume` comes into play:

    suspend(function* (resume) {
        var data = yield fs.readFile(__filename, resume);
    })();

As can be seen, when the generator is initialized, it is passed a reference to `resume`, which is nothing more than a reusable callback, bound to the resulting iterator, and just barely smart enough to understand Node.js' callback conventions.  All arguments passed to `resume` are available in an array, which is the result of the yield assignment:

    suspend(function* (resume) {
        var data = yield fs.readFile(__filename, resume);
        // the Buffer returned from readFile is available in the first index
        console.log(data[0].toString('utf8'));
    })();

Any arguments passed to the initializer are available following the `resume` parameter:

    suspend(function* (resume, fileName) {
        var data = yield fs.readFile(fileName, resume);
        console.log(data[0].toString('utf8'));
    })(__filename);

## License 

The MIT License (MIT)

Copyright (c) 2013 Jeremy Martin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

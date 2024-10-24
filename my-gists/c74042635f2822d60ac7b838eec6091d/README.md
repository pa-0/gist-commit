## `Stashy` is a really simple Key-Value Store

Source URL: [**SecretGeek** (https://secretgeek.net/)](https://secretgeek.net/stashy_gist) <br/>November 12, 2020

#microsoft #UX #security #code #csharp #dotnet #key-value-pair #json

In my various websites and web applications, I often need to store some things and later retrieve them. Mostly for this I use a really simple key value store called "`Stashy`", that I built, oh, decades ago. Imagine I have a "plain old class object", and I want to save it. It might be an object called "myNewBlogPost".

I will call:

```csharp
stashy.Save<BlogPost>(myNewBlogPost, myNewBlogPost.Slug);
```

Later, if I want to load that blog post, I will need to know the key I used, let's say it was "hello-world":

```csharp
var myNewBlogPost = stashy.Load<BlogPost>("hello-world");
```

And there's also a method for loading all objects of a given type:

```csharp
var myBlogPosts = stashy.LoadAll<BlogPost>();
```

And for deleting a single object:

```csharp
stashy.Delete<BlogPost>("hello-world");
```

_And that's it!_

It's not distributed. It doesn't have a query language. It doesn't have built in caching semantics. It's not even async.

I tell you what it does have: **utility**. It's bloody useful! I would definitely not consider it for cases with millions of records, but 1000 or under? It's _fine!_ And one less thing to worry about.

The `Stashy` class is an implementation of the `IStashy` interface. This makes it easier to test, and helps me with the dependency injection stuff. Mostly it serves to make sure I'm keeping the contract _small_.

The `IStashy` interface is just this:

```csharp
public interface IStashy<K>
{
    void Save<T>(T t, K id);
    T Load<T>(K id);
    IEnumerable<T> LoadAll<T>();
    void Delete<T>(K id);
    K GetNewId<T>();
}
```

The type `K` is the type of key you want to use. I usually use strings as my key. But you can use integers or guids, or anything else, if you like.

As I tweeted recently, [The heart and soul of my most used key-value store fits in a single tweet. Easily!](https://twitter.com/secretGeek/status/1327038572558393345?s=20)

I've used a couple of different implementations of this interface over the years, but currently what it does is serialize the object as `JSON` and then store it in a file named after the key, in a sub-folder named after the `type` of the object. (I also have a completely in-memory implementation, for testing etc.)

Here's an implementation I use at the moment in one of my projects. It is _not_ glorious beautiful wondrous code, but it is working code that I just... well I just never have to look at it. But I rely on it _all_ the time:

![see gist: FileStashy.cs](https://gist.github.com/secretGeek/1afc53356373cc4c790876adf6a356cf)

It's about 100 lines of code, written _years_ ago, and relies on `Newtonsoft.Json` to turn objects into Json and vice-versa.

(10 years ago my FileStashy used XML, on Windows... Now it's all Json, and runs anywhere that .net core runs. Maybe one day, one _special_ day, we'll all switch to [CSV](https://github.com/secretGeek/AwesomeCSV).)

Sometimes I build other stuff on-top of Stashy, such as indexes, for faster lookups, and "revisions", so I can look at old versions of an object. That was easy enough to write (and very fun of course!) but I wouldn't want to do too much with it, or I'd switch to a _real_ key value store... but then get all the headaches that come from those.

Got any crafty little things you've rolled yourself instead of using something "better"?

### Comments

#### Doeke Zanstra on November 13, 2020 03:28 sez:

Nice. I like simple. It looks a bit like Apple’s defaults system. But not exactly. Would you mind sharing some use cases?  
  
https://ss64.com/osx/defaults.html

#### [lb](https://secretgeek.net/) on November 13, 2020 04:24 sez:

I use it for all the sorts of things that normal people use a database for.  
  
In this website it stores all the blogposts and the comments. The wiki has similar stuff. Other little sites of mine use a sqlite dB instead. That’s harder to deal with schema changes but better for querying.

#### [Doeke](https://blog.zanstra.com/) on November 15, 2020 15:24 sez:

Ah, now it makes more sense. Maybe the title of this blog should be "Good Enough" (as in Boeing 747 was good enough in comparison to the Concorde).

#### Al Gonzalez on December 08, 2021 11:36 sez:

Based on the interface signature for `Save`**:** 

```csharp
void Save(T t, K id);
```  

Shouldn't the first example have the arguments be reversed? So:

```csharp
stashy.Save(myNewBlogPost, myNewBlogPost.Slug);
```

#### [lb](https://secretgeek.net/) on December 09, 2021 20:17 sez:

You’re right Al- first example has parameters in wrong order. 😖

#### [lb](https://secretgeek.net/) on November 19, 2022 00:47 sez:

@Al Gonzales -- I fixed that first example now. cheers

#### Nx on June 21, 2024 05:20 sez:

I think this could be even better if the objects were stored into a single file, rather than a multitude of files. For development that's alright but I wouldn't want to keep creating and reading files during runtime.

#### [lb](https://secretgeek.net/) on June 21, 2024 05:34 sez:

Good thinking.  
  
A single file implementation is easy too, and allows easier - though still necessarily strictly correct -- file handling -- (ensure atomic operations on the file)  
  
Depending on your scenario, there will be very clear "patterns of usage" in your directed acyclic graph of things. For example, you may find that data is "read" thousands of times for every "write" to. In that case, a caching strategy is helpful to prevent needless deep seeks to hard disk. And given large available memory sizes today, we can pre-load some, most, or even "all" of the core of the current database.  
  
What's that strategy, that manifesto? "Just Keep It In RAM. RAM is big. Everything fits in RAM."?
# 나의 링크
원본: Notion 데이터베이스 "나의 링크"

총 35개 북마크 (본문 포함)

---

## 1. domain object
> 생성: 2019-05-08

_(본문 없음)_

---

## 2. [How to Connect an Electronic Balance or Scale to a PC and Read Weight Values Directly Into Excel](https://www.instructables.com/How-to-Connect-an-Electronic-Balance-or-Scale-to-a/#step3)
> 생성: 2020-12-08

_(본문 없음)_

---

## 3. [Design patterns in TypeScript and Node.js - LogRocket Blog](https://blog.logrocket.com/design-patterns-in-typescript-and-node-js/)
> 생성: 2021-01-28

Design patterns are solutions to recurring problems in software application development.

As we all know, there are three types of design patterns. They are:

- Creational

- Structural

- Behavioral

But, wait. what does that mean?

Creational pattern is concerned with the way we create objects in an object-oriented style. it applies patterns in the way we instantiate a class.

Structural pattern is concerned with how our classes and objects are composed to form a larger structure in our application.

Behavioral pattern is concerned about how the objects can interact efficiently without being tightly coupled.

This tutorial will explain to you some of the most common design patterns that you can use in your Node.js Application. we will be using Typescript to make the implementation easier.

#### Singleton

The singleton pattern implies that there should be only one instance for a class. In laymen’s terms, there should be only one president for a country at a time. By following this pattern, we can avoid having multiple instances for a particular class.

A good example of the Singleton pattern is database connection in our application. Having multiple instances of a database in our application makes an application unstable. So, the singleton pattern provides a solution to this problem by managing a single instance across the application.

Let’s see how to implement the above example in Node.js with Typescript:

```plain text
import {MongoClient,Db} from 'mongodb'classDBInstance{

    private static instance: Db

    private constructor(){}

    static getInstance() {
        if(!this.instance){
            const URL = "mongodb://localhost:27017"
            const dbName = "sample"    
            MongoClient.connect(URL,(err,client) => {
                if (err) console.log("DB Error",err)
                const db = client.db(dbName);
                this.instance = db
            })

        }
        return this.instance
    }}export default DBInstance
```

Here, we have a class, DBInstance, with an attribute instance. In DBInstance, we have the static method getInstance where our main logic resides.

It checks if there is a database instance already. If there is, it will return that. Otherwise, it will create a database instance for us and return it.

Here’s an example of how we can use the singleton pattern inside our API routes:

```plain text
import express,{  Application, Request, Response } from 'express'import DBInstance from './helper/DB'import bodyParser from 'body-parser'const app = express()async function start(){

    try{

        app.use(bodyParser.json())
        app.use(bodyParser.urlencoded({extended : true}))
        const db = await DBInstance.getInstance()

        app.get('/todos',async (req : Request,res : Response) => {
            try {
                const db = await DBInstance.getInstance()

                const todos = await db.collection('todo').find({}).toArray()
                res.status(200).json({success : true,data : todos})
            }
            catch(e){
                console.log("Error on fetching",e)
                res.status(500).json({ success : false,data : null })
            }
            
        })

        app.post('/todo',async (req : Request,res : Response) => {
            try {
                const db = await DBInstance.getInstance()

                const todo = req.body.todos
               const todoCollection =  await db.collection('todo').insertOne({ name : todo })

                res.status(200).json({ success : true,data : todoCollection })
            }
            catch(e){
                console.log("Error on Inserting",e)
                res.status(500).json({ success : false,data : null })
            }
        })

        app.listen(4000,() => {
            console.log("Server is running on PORT 4000")
        })
    }
    catch(e){
        console.log("Error while starting the server",e)
    }}

start()
```

#### Abstract factory

Before getting into the explanation of abstract factory, I want you to know what it means by factory pattern.

##### Simple factory

To make it simpler, let me give you an analogy. Let’s say that you are hungry and want some food. You can either cook for yourself or you can order from a restaurant. In that way, you don’t need to learn or know how to cook to eat some food.

Similarly, the Factory pattern simply generates an object instance for a user without exposing any instantiation logic to the client.

Now that we know about the simple factory pattern, let’s come back to the abstract factory pattern. Extending our simple factory example, let’s say you are hungry and you’ve decided to order food from a restaurant. Based on your preference, you might order a different cuisine. Then, you might need to select the best restaurant based on the cuisine.

As you can see, there is a dependency between your food and the restaurant. Different restaurants are better for different cuisine.

Let’s implement an abstract factory pattern inside our Node.js Application. Now, we are going to build a laptop store with different kinds of computers. A few of the main components are Storage and Processor.

Let’s build an interface for it:

```plain text
export default interface IStorage {
     getStorageType(): string}import IStorage from './IStorage'export default interface IProcessor {
    attachStorage(storage : IStorage) : string

    showSpecs():string}
```

Next, let’s implement the storage and processor interfaces in classes:

```plain text
import IProcessor from '../../Interface/IProcessor'import IStorage from '../../Interface/IStorage'export default classMacbookProcessorimplementsIProcessor{

    storage: string | undefined

    MacbookProcessor() {
        console.log("Macbook is built using apple silicon chips")    
    }

    attachStorage(storageAttached: IStorage) {
        this.storage = storageAttached.getStorageType()
        console.log("storageAttached",storageAttached.getStorageType())
        return this.storage+" Attached to Macbook"
    }
    showSpecs(): string {
        return this.toString()
    }

    toString() : string {
        return "AppleProcessor is created using Apple Silicon and "+this.storage;
    }}import IProcessor from '../../Interface/IProcessor'import IStorage from '../../Interface/IStorage'export default classMacbookStorageimplementsIStorage{

    storageSize: number

    constructor(storageSize : number) {
        this.storageSize = storageSize
        console.log(this.storageSize+" GB SSD is used")
    }

    getStorageType() {
        return  this.storageSize+"GB SSD"
    }}
```

Now, we’ll create a factory interface, which has methods such as createProcessor and createStorage.

```plain text
import IStorage from '../Interface/IStorage'import IProcessor from '../Interface/IProcessor'export default interface LaptopFactory {
    createProcessor() : IProcessor

    createStorage() : IStorage}
```

Once the factory interface is created, implement it in the laptop class. Here, it will be:

```plain text
import LaptopFactory from '../../factory/LaptopFactory'import MacbookProcessor from './MacbookProcessor'import MacbookStorage from './MacbookStorage'export classMacbookimplementsLaptopFactory{
    storageSize: number;

    constructor(storage : number) {
        this.storageSize = storage
    }

    createProcessor() : any{
        return new MacbookProcessor()
    }

    createStorage(): any {
        return new MacbookStorage(this.storageSize)
    }}
```

Finally, create a function that calls factory methods:

```plain text
import LaptopFactory from '../factory/LaptopFactory'import IProcessor from '../Interface/IProcessor'export const buildLaptop =  (laptopFactory : LaptopFactory) : IProcessor=> {
    const processor = laptopFactory.createProcessor()

    const storage = laptopFactory.createStorage()

    processor.attachStorage(storage)

    return processor
}
```

#### Builder pattern

The builder pattern allows you to create different flavors of an object without using a constructor in a class.

But why, can’t we just use a constructor?

Well, there is a problem with the constructor in certain scenarios. Let’s say that you have a User model and it has attributes such as:

```plain text
export default classUser{

    firstName: string
    lastName : string
    gender: string
    age: number
    address: string
    country: string
    isAdmin: booleanconstructor(firstName,lastName,address,gender,age,country,isAdmin){
        this.firstName = builder.firstName
        this.lastName = builder.lastName
        this.address = builder.address
        this.gender = builder.gender
        this.age = builder.age
        this.country = builder.country
        this.isAdmin = builder.isAdmin
    }}
```

To use this, you may need to instantiate it like this:

```plain text
const user = new User("","","","",22,"",false)
```

Here, we have a limited argument. However, it will be hard to maintain once the attributes increase. To solve this problem, we need the builder pattern.

Create a builder class like this:

```plain text
import User from './User'export default class UserBuilder {

    firstName = ""
    lastName = ""
    gender = ""
    age = 0
    address = ""
    country = ""
    isAdmin = falseconstructor(){
        
    }

    setFirstName(firstName: string){
        this.firstName = firstName
    }

    setLastName(lastName : string){
        this.lastName = lastName
    }

    setGender(gender : string){
        this.gender = gender
    }

    setAge(age : number){
        this.age = age
    }

    setAddress(address : string){
        this.address = address
    }

    setCountry(country : string){
        this.country = country
    }

    setAdmin(isAdmin: boolean){
        this.isAdmin = isAdmin
    }

    build() : User {
        return new User(this)
    }

    getAllValues(){
        return this
    }}
```

Here, we use getter and setter to manage the attributes in our builder class. After that, use the builder class inside our model:

```plain text
import UserBuilder from './UserBuilder'export default class User {

    firstName: string
    lastName : string
    gender: string
    age: number
    address: string
    country: string
    isAdmin: booleanconstructor(builder :UserBuilder){
        this.firstName = builder.firstName
        this.lastName = builder.lastName
        this.address = builder.address
        this.gender = builder.gender
        this.age = builder.age
        this.country = builder.country
        this.isAdmin = builder.isAdmin
    }}
```

#### Adapter

A classic example of an adapter pattern will be a differently shaped power socket. Sometimes, the socket and device plug doesn’t fit. To make sure it works, we will use an adapter. That’s exactly what we are going to do in the adapter pattern.

It is a process of wrapping the incompatible object in an adapter to make it compatible with another class.

So far we have seen an analogy to understand the adapter pattern. Let me give you a real use case where an adapter pattern can be a life saver.

Consider that we have a CustomerError class:

```plain text
import IError from '../interface/IError'export default classCustomErrorimplementsIError{

    message : string

    constructor(message : string){
        this.message = message
    }

    serialize() {
        return this.message
    }}
```

Now, we are using this CustomError class across our application. After some time, we need to change the method in the class due to some reason.

New Custom Error class will be something like this:

```plain text
export default classNewCustomError{

    message : stringconstructor(message :string){
        this.message = message    
    }

    withInfo() {
        return { message : this.message } 
    }}
```

Our new change will crash the entire application since it changes the method. To solve this problem, the adapter pattern comes into play.

Let’s create an adapter class and solve this problem:

```plain text
import NewCustomError from './NewCustomError'// import CustomError from './CustomError'export default classErrorAdapter{
    message : string;
    constructor(message : string) {
        this.message = message
    }

    serialize() {
              // In future replace this function
        const e = new NewCustomError(this.message).withInfo()
        return e
    }}
```

The serialize method is what we use in our entire application. Our application doesn’t need to know which class we are using. The Adapter class handles it for us.

#### Observer

An Observer pattern is a way to update the dependents when there is a state change in another object. it usually contains Observer and Observable. Observer subscribes to Observable and where there is a change, observable notifies the observers.

To understand this concept, let’s take a real use case for the observer pattern:

Here, we have Author, Tweet, and follower entities. Followers can subscribe to the Author . Whenever there’s a new Tweet, the follower is updated.

Let’s implement it in our Node.js application:

```plain text
import Tweet from "../module/Tweet";export default interface IObserver {
    onTweet(tweet : Tweet): string}import Tweet from "../module/Tweet";export default interface IObservable{

    sendTweet(tweet : Tweet): any
}
```

Here, we have the interface IObservable and IObserver, which has onTweet and sendTweet methods in it.

```plain text
import IObservable from "../interface/IObservable";import Tweet from "./Tweet";import Follower from './Follower'export default classAuthorimplementsIObservable{

    protected observers : Follower[] = []

    notify(tweet : Tweet){
        this.observers.forEach(observer => {
            observer.onTweet(tweet)
        })
    }

    subscribe(observer : Follower){
        this.observers.push(observer)
    }

    sendTweet(tweet : Tweet) {
        this.notify(tweet)
    }}
```

Follower.ts

```plain text
import IObserver from '../interface/IObserver'import Author from './Author'import Tweet from './Tweet'export default classFollowerimplementsIObserver{

    name : string

    constructor(name: string){
        this.name = name
    }

    onTweet(tweet: Tweet) {
        console.log( this.name+" you got tweet =>"+tweet.getMessage())
        return this.name+" you got tweet =>"+tweet.getMessage()
    }}
```

```plain text
export default classTweet{

    message : string
    author: stringconstructor(message :string,author:string){
        this.message = message
        this.author= author
    }

    getMessage() : string {
        return this.message+" Tweet from Author: "+this.author
    }}
```

index.ts

```plain text
import express,{  Application, Request, Response } from 'express'// import DBInstance from './helper/DB'import bodyParser from 'body-parser'import Follower from './module/Follower'import Author from './module/Author'import Tweet from './module/Tweet'const app = express()async function start(){

    try{

        app.use(bodyParser.json())
        app.use(bodyParser.urlencoded({extended : true}))
        // const db = await DBInstance.getInstance()

        app.post('/activate',async (req : Request,res : Response) => {
            try {

                const follower1 = new Follower("Ganesh")
                const follower2 = new Follower("Doe")

                const author = new Author()

                author.subscribe(follower1)
                author.subscribe(follower2)

                author.sendTweet(
                   new Tweet("Welcome","Bruce Lee")
                )

                res.status(200).json({ success : true,data:null })

            }
            catch(e){
                console.log(e)
                res.status(500).json({ success : false,data : null })
            }
        })

        app.listen(4000,() => {
            console.log("Server is running on PORT 4000")
        })
    }
    catch(e){
        console.log("Error while starting the server",e)
    }}

start()
```

#### Strategy pattern

The strategy pattern allows you to select an algorithm or strategy at runtime. The real use case for this scenario would be switching file storage strategy based on the file size.

Consider that you want to handle file storage based on file size in your application:

Here, we want to upload the file and decide the strategy based on the file size, which is a run time condition. Let’s implement this concept using a strategy pattern.

Create an interface that needs to be implemented by a Writer class:

```plain text
export default interface IFileWriter {
    write(filepath: string | undefined) : boolean}
```

After that, create a class to handle files if it’s larger in size:

```plain text
import IFileWriter from '../interface/IFileWriter'export default classAWSWriterWrapperimplementsIFileWriter{

    write() {
        console.log("Writing File to AWS S3")
        return true
    }}
```

Then, create a class to handle files which are smaller in size:

```plain text
import IFileWriter from '../interface/IFileWriter'export default classDiskWriterimplementsIFileWriter{

    write(filepath : string) {
        console.log("Writing File to Disk",filepath)
        return true
    }}
```

Once we have both of them, we need to create the client that can use any strategy in it:

```plain text
import IFileWriter from '../interface/IFileWriter'export default classWriter{

    protected writer
    constructor(writer: IFileWriter) {
        this.writer = writer
    }

    write(filepath : string) : boolean {
        return this.writer.write(filepath)
    }}
```

Finally, we can use the strategy based on the condition that we have:

```plain text
let size = 1000

                if(size < 1000){
                    const writer = new Writer(new DiskFileWriter())
                    writer.write("file path comes here")
                }
                else{
                    const writer = new Writer(new AWSFileWriter())
                    writer.write("writing the file to the cloud")
                }
```

##### Chain of responsibility

The chain of responsibility allows an object to go through a chain of conditions or functionalities. Instead of managing all the functionalities and conditions in one place, it splits into chains of conditions that an object must pass through.

One of the best example for this pattern is express middleware:

We build functions as a middleware that is tied up with each request in the express. Our request must pass the condition inside the middleware. It is the best example of a chain of responsibility:

---

## 4. [Python VS JavaScript – What are the Key Differences Between The Two Popular Programming Languages?](https://www.freecodecamp.org/news/python-vs-javascript-what-are-the-key-differences-between-the-two-popular-programming-languages/)
> 생성: 2021-01-29

Welcome! If you want to learn the differences between Python and JavaScript, then this article is for you.

These two languages are very popular and powerful, but they do have key differences. We will cover them in detail here.

In this article, you will learn:

- The different real-world applications of Python and JavaScript.

- The key syntactic and functional differences between Python and JavaScript.

Let's begin! ✨

#### 🔹 Python VS JavaScript: Real-World Applications

We will start with a quick tour of their real-world applications.

##### Python

Python has become an essential tool in virtually every scientific application around the world because of its power and versatility. It is a general-purpose programming language that supports different programming paradigms.

It is widely used in scientific and specialized applications, including data science, artificial intelligence, machine learning, computer science education, computer vision and image processing, medicine, biology, and even astronomy.

It is also used for web development. This is where we can start to compare its applications to the applications of JavaScript. Python is used for back-end development, which is the area of web development in charge of creating the elements that users don't see, such as the server side of an application.

##### JavaScript

While Python can be used to develop the back-end part of a web application, JavaScript can be used to develop both the back-end and the front-end of the application.

The front-end is the part of the application that the user sees and interacts with. Whenever you see or interact with a website or web application, you are using JavaScript "behind the scenes".

Similarly, when you interact with a mobile app, you might be using JavaScript because frameworks like React Native let us write applications that adapt to different platforms.

JavaScript is so widely used in web development because it is a versatile language that gives us the tools we need to develop the components of a web application.

##### Differences between the applications of Python and JavaScript

When we compare the real-world applications of JavaScript with the real-world applications of Python, we can immediately see that JavaScript is not particularly used for scientific applications while Python is.

This is one of the main differences between these two languages. JavaScript is more focused on the area of web development whereas Python has a wider range of applications.

#### 🔸 Python VS JavaScript: Syntax

Now that you know what they are used for, let's see how they are written and the differences in their syntax.

We will cover the differences in their main elements:

- Code Blocks

- Variable Definitions

- Variable Naming Conventions

- Constants

- Data Types and Values

- Comments

- Built-in Data Structures

- Operators

- Input/Output

- Conditional Statements

- For Loops and While Loops

- Functions

- Object-Oriented Programming

#### Code Blocks in Python and JavaScript

Each programming language has its own style to define code blocks. Let's see their differences in Python and JavaScript:

##### How Python defines code blocks

Python relies on indentation to define code blocks. When a series of continuous lines of code are indented at the same level, they are considered part of the same code block.

We use this to define conditionals, functions, loops, and basically every compound statement in Python.

These are some examples:

Use of indentation to define code blocks in Python

💡 Tip: We will see the specific differences between these elements in Python and JavaScript in just a moment. At this moment, please focus on the indentation.

##### How JavaScript defines code blocks

In contrast, in JavaScript we use curly braces ({}) to group statements that belong to the same code block.

These are some examples:

Use of curly braces to define code blocks in JavaScript

#### Variable Definitions in Python and JavaScript

The assignment statement is one of the most fundamental statements in any programming language. Let's see how we can define a variable in Python and JavaScript.

##### How to define a variable in Python

To define a variable in Python, we write the name of the variable followed by an equal sign (=) and the value that will be assigned to the variable.

Like this:

```plain text
<variable_name> = <value>
```

For example:

##### How to define a variable in JavaScript

The syntax is very similar in JavaScript, but we just need to add the keyword var before the name of the variable and end the line with a semicolon (;).

Like this:

```plain text
var <variable_name> = <value>;
```

💡 Tip: When you define a variable using var, the variable has function scope.

For example:

```plain text
var x = 5;
```

We can also use the keyword let:

```plain text
let <variable_name> = <value>;
```

For example:

```plain text
let x = 5;
```

💡 Tip: In this case, when we use let, the variable will have block scope. It will only be recognized in the code block where it was defined.

Variable definitions in Python and JavaScript

💡 Tip: In JavaScript, the end of a statement is marked with a semicolon (;) but in Python, we just start a new line to mark the end of a statement.

#### Variable Naming Conventions in Python and JavaScript

Python and JavaScript follow two different variable naming conventions.

##### How to name variables in Python

In Python, we should use the snake_case naming style.

According to the Python Style Guide:

> Variable names follow the same convention as function names.Function names should be lowercase, with words separated by underscores as necessary to improve readability.

Therefore, a typical variable name in Python would look like this:

```plain text
first_name
```

💡 Tip: The style guide also mentions that "mixedCase is allowed only in contexts where that's already the prevailing style, to retain backwards compatibility."

##### How to name variables in JavaScript

In contrast, we should use the lowerCamelCase naming style in JavaScript. The name starts with a lowercase letter and then every new word starts with an uppercase letter.

According to the JavaScript guidelines article by the MDN Web Docs:

> For variable names use lowerCamelCasing, and use concise, human-readable, semantic names where appropriate.

Therefore, a typical variable name in JavaScript should look like this:

```plain text
firstName
```

#### Constants in Python and JavaScript

Great. Now you know more about variables, so let's talk a little bit about constants. Constants are values that cannot be changed during the execution of the program.

##### How to define constants in Python

In Python, we rely on naming conventions to define constants because there are no strict rules in the language to prevent changes to their values.

According to the Python Style Guide:

> Constants are usually defined on a module level and written in all capital letters with underscores separating words.

This is the naming style that we should use to define a constant in Python:

```plain text
CONSTANT_NAME
```

For example:

```plain text
TAX_RATE_PERCENTAGE = 32
```

---

## 5. https://www.typescriptlang.org/docs/handbook/functions.html
> 생성: 2021-01-30

_(본문 없음)_

---

## 6. [paper css print](https://github.com/cognitom/paper-css)
> 생성: 2021-02-15

_(본문 없음)_

---

## 7. [How to Create a CSS Grid Layout for Divi Modules](https://www.elegantthemes.com/blog/divi-resources/how-to-create-a-css-grid-layout-for-divi-modules)
> 생성: 2021-04-02

For those already familiar with building websites in Divi, creating custom grid layouts is a core aspect of the Divi Builder. Simply create a row and choose from multiple built-in column layouts for that row. Once the column layout is in place, we simply add the content/modules we want inside each column. But, what if we wanted an additional grid layout for those modules?

In this tutorial, we are going to explore how to expand upon Divi’s grid layouts by creating CSS grid layouts for Divi modules within a single column. The CSS Grid property (along with CSS Flex) is a popular way to create predictable and responsive grid layouts for content with just a few lines of CSS. With it, we can organize all the modules in a column into a fully responsive grid. Think of it as an additional grid layout for modules that you can add to any Divi column. But one of the best things about this technique is that each adjacent module will have the same height and width without all the hassle of trying to do this using custom padding or height values on each module.

Perhaps it is best that we just jump in and show you how this works.

Let’s get started!

#### Sneak Peek

Here is a quick look at the design we’ll build in this tutorial.

And here is a peek at the same technique using different modules and designs from the Fitness Gym Layout Pack.

#### Download the Layout for FREE

To lay your hands on the designs from this tutorial, you will first need to download it using the button below. To gain access to the download you will need to subscribe to our Divi Daily email list by using the form below. As a new subscriber, you will receive even more Divi goodness and a free Divi Layout pack every Monday! If you’re already on the list, simply enter your email address below and click download. You will not be “resubscribed” or receive extra emails.

#### Download For Free

Join the Divi Newsletter and we will email you a copy of the ultimate Divi Landing Page Layout Pack, plus tons of other amazing and free Divi resources, tips and tricks. Follow along and you will be a Divi master in no time. If you are already subscribed simply type in your email address below and click download to access the layout pack.

To import the section layout to your Divi Library, navigate to the Divi Library.

Click the Import button.

In the portability popup, select the import tab and choose the download file from your computer.

Then click the import button.

Once done, the section layout will be available in the Divi Builder.

Let’s get to the tutorial, shall we?

#### What You Need to Get Started

To get started, you will need to do the following:

1. If you haven’t yet, install and activate the Divi Theme.

1. Create a new page in WordPress and use the Divi Builder to edit the page on the front end (visual builder).

1. Choose the option “Build From Scratch”.

After that, you will have a blank canvas to start designing in Divi.

#### Creating a Custom CSS Grid Layout For Divi Modules

##### Part 1: Adding The Modules to a Divi Column

Before we organize our modules into a grid layout, let’s first add all the modules we want to use to our column.

To start, create a new one-column row to the default regular section in the Divi Builder.

##### Creating the Modules

Inside the column of the row, add a new text module. Then update the content settings of the module as follows:

1. Add an H2 heading above the paragraph text of the default body content

1. Background Color: #333333

Then update the design settings as follows:

1. Text Font: Poppins

1. Text Color: Light

1. Select the H2 tab under Heading Text

1. Heading 2 Font Style: TT

1. Padding: 10% top, 10% bottom, 10% left 10% right

NOTE: For simplicity, we are going to stick with using multiple text modules with various background colors to show a distinction between each module. But, as I’ll explain later, you can use any combination of modules you want (blurb modules, call to action modules, contact form modules, etc.).

Open the layers view (optional) and create the next text module as follows:

1. Duplicate the text module.

1. Open the text settings for the duplicate module.

1. Update the Background Color 

Repeat this process to create the third text module as follows:

1. Duplicate the previous text module.

1. Open the text settings for the duplicate module.

1. Update the Background Color 

Repeat this process one more time to create the fourth text module as follows:

1. Duplicate the previous text module.

1. Open the text settings for the duplicate module.

1. Update the Background Color 

To create the next four modules, use the multiselect feature to select all four modules. Then copy and paste the modules in the same column to create a total of eight text modules.

##### Part 2: Creating the CSS Grid Layout for the Modules

Now that our modules are in place, we are ready to create our CSS Grid for those modules.

##### Row Settings

For this example, we are using a one-column layout so that we can display our module grid in a full-width layout. So we will need to update the row settings to make sure the row spans the full width of the page. We also need to take out the default gutter width so that no additional margins are added to our modules.

Open the row settings and update the following:

- Gutter Width: 1

- Width: 100%

- Max-width: 100%

##### Adding CSS Grid to the Column to Build the Grid Layout for the Modules

This is the key step in the tutorial that creates the layout for the modules using the CSS Grid property.

To do this, we are going to add three lines of CSS to the Column that will determine the layout of our modules.

Open the column settings and, under the advanced tab, paste the following CSS inside the Main Element:

The first line of CSS lays out the content (or modules) according to the CSS grid module.

display:grid

The second line of CSS defines the column template of the grid. In this case, the grid will have four columns that are each 25% in width (see screenshot above).

grid-template-columns: 25% 25% 25% 25%

The third line of CSS specifies that rows will be auto-generated as needed with a size (or height) set to auto. This means the height of each row will be determined by the vertical height of the content (or modules) within the row (see screenshot above).

grid-auto-rows: auto

##### Adjust Grid Layout on Mobile

We will also need to adjust the grid layout on mobile devices as needed.

To do this we simply need to add additional CSS to each tablet an mobile that changes the number of columns and the width of each column.

In this example, we are going to change the grid layout for the modules on tablet to be two columns that are each 50% in width.

Open the responsive options and select tablet tab under the main element and paste the following CSS:

For phone display, we want a single-column layout. To create this, paste the following CSS under the Phone tab Main Element:

##### Part 3: Making Changes to the Grid Items (or Modules)

##### Adding a New Module to the Grid and How it Reacts

Now that each module is inside the CSS grid, adding a new module will push the other modules to the right and create new rows automatically as needed.

Since we need one more module for this layout anyway, duplicate the first text module to see how the other modules adjust within the grid.

Right now, all the text modules have the same amount of content so it is hard to see how the grid layout handles modules with varying amounts of content. To see how this works, change the amount of paragraph text within each module. Notice that the modules will remain the same height as the module with most content in the same row. And the row height will also be determined by the module with the most content (or vertical height).

##### Changing the Position of Modules (or grid items)

CSS Grid items can be positioned using the built-in line numbering system of the grid module. Each line on the grid represents a number. For the columns, the line numbers start at 1 and continue horizontally. Each line number sits at the beginning and end of each column. So, for our four-column structure, the line number begins at 1 on the left of the first column and ends at 5 on the right side of the fourth column. And, since we have three rows, the line numbers for rows start at 1 at the top of the first row and continue to 4 at the bottom of the third row.

To change the position of a module (or grid item) in CSS Grid, we can set define where we want a certain module to be placed in the grid. This will override the default placement of the module in the grid.

For this example, we are going to move the first text module to a different position. To do this we need to add two lines of CSS to the module.

Open the settings for the first text module and paste the following custom CSS to the main element:

The first line of CSS defines the position of the module (or grid item) horizontally by telling the module to start on column line 2 and end on column line 4.

grid-column: 2/4

The second line of CSS defines the position of the module (or grid item) vertically by telling the module to start on row line 2 and end on row line 3.

grid-row: 2/3

For tablet and phone display, we want to bring the module back to the original location. This is helpful for keeping your main header at the top of the page.

To do this, select the tablet tab under the responsive option for the main element and paste the following CSS:

Now the position of the module will go back to the original (automatic) flow of the grid items.

---

## 8. B2B 입찰플랫폼 투자ㅣ6개월만에 1,000여개 기업 가입 프로젝트 투자자 모집
> 생성: 2021-09-08

_(본문 없음)_

---

## 9. 페이지 제목
> 생성: 2021-09-08

_(본문 없음)_

---

## 10. [입찰정보 DeepBid](http://www.deepbid.com)
> 생성: 2021-09-08

_(본문 없음)_

---

## 11. [Workshop Studio](https://catalog.us-east-1.prod.workshops.aws/workshops/3fd6c80b-39f2-4534-b69c-c400aed50c67/ko-KR/)
> 생성: 2022-05-26

_(본문 없음)_

---

## 12. [개발자](http://channy.creation.net/blog/1600)
> 생성: 2022-06-30

예전에 “훌륭한 개발 문화의 이면“이라는 시리즈를 연재한 적이 있습니다. 최근 IT 기업 사이에서 개발자 연봉이나 복지 부분에 대한 개선이 이루어지는 현상이 일어나고 있어 매우 고무적인데요. 그런데, 기업 내 개발 환경이나 문화에 대한 개선이 잘 이루어지고 있는지가 궁금했습니다.

지난 6월 10일 부터 27일까지 2022년 국내 기업 개발자 문화 현황 조사를 실시하였습니다. 제가 늘 중요하게 생각하는 12가지 항목을 선정했는데, 개인의 개발 환경, 팀의 업무 문화, 기업의 협업 방식, 기술 경력 및 공유 등 4가지 파트에서 3개씩 골랐습니다. (비슷한 접근 방식으로는 조엘 테스트 (2000)와 실용적 엔지니어 테스트(2021) 같은 것이 있습니다.)

##### Channy의 12가지 훌륭한 개발 문화 체크리스트

1. 코딩 테스트 인터뷰 – 개발자 입사 시 코딩 테스트 혹은 화이트 보드 인터뷰를 진행한다.

1. 자율적 개인 개발 장비 선택 – 회사에 업무 장비 표준 (PC, 노트북 등)이 있더라도, 개인별로 원하는 개발 장비를 선택할 수 있다.

1. 자율적 팀 개발 환경 선택 – 회사에 기술 표준 (프로그래밍 언어, 플랫폼 등)이 있더라도, 팀별로 원하는 개발 환경을 선택할 수 있다.

1. 소스 코드 리뷰 및 테스트 – 모든 개발자가 다른 사람의 소스 커밋을 리뷰하고, 테스트하는 과정을 가지고 있다.

1. 개발자 기여 로드맵/백로그 – 주요 개발 방향을 PM/기획 뿐만 아니라 개발자들이 주도 혹은 참여해서 정해나간다.

1. 지속적 통합 및 배포 (CI/CD) – 코드 커밋 후 자동으로 통합 및 배포되는 시스템을 가지고 있다.

1. 내부 소스 레포지터리 공유 – 다른 팀의 소스 코드에 접근(access), 포크(fork) 혹은 기여(contribution)할 수 있다.

1. API를 기반한 연동 및 소통 – 내부 팀 및 플랫폼간 협업을 할 때, API를 개발해서 공유하거나, 검색할 수 있다.

1. 기술을 이해하는 팀장/매니저 – 회사 내 개발팀장 대부분은 소프트웨어 개발 경력이 가지고 있으며, 내부 코드 및 기술 플랫폼을 이해하는 사람이다.

1. 개발자 레벨 혹은 경력 관리 – 사내에 개발자의 업무 역량별 레벨 제도 혹은 팀장/매니저가 아닌 별도의 개발자 전용 승진 경로를 가지고 있다.

1. 참여형 지식 공유 플랫폼 – 사내에 직접 참여 혹은 편집 가능한 위키(노션), 블로그 플랫폼을 운영하고 있다.

1. 개발자 관계(DevRel) 활동 – 외부 개발자와 소통하는 채널(기술 블로그, 컨퍼런스 등)을 운영하거나 전담하는 사람/팀이 있다.

1. 위의 모든 사항이 해당 안된다 ㅠㅠ (13일의 금요일의 저주)

본 설문 조사는 원티드랩에서 홍보에 도움을 주셔서 총 415분이 응답해 주셨습니다. 직군별로 보면, 백엔드 엔지니어 (41.9%), 프론트엔드 엔지니어(26.6%), 데이터 엔지니어(7.3%), 시스템엔지니어 (6%), 풀스택 및 기타 엔지니어 (18.3%)입니다. 이 중에는 기업별로 중복된 분들도 계신데, 총 278개 기업에 재직중이었습니다.

국내 개발문화 조사 응답자 직군 분포도

총 278개 기업 중에 “해당 사항이 아무 것도 없다”고 응답하신 13일의 금요일의 저주(?)에 걸리신 분들이 31개로 12.5%였습니다. 이들 회사를 제외하고, 한개라도 해당되는 게 있다고 응답한 총 247개 회사의 결과를 공개하겠습니다. (단, 직원수가 많아서 항목별 중복 응답이 있는 회사의 경우, 응답자 중 적어도 50%이상이 체크한 항목만 반영하였습니다.)

평균적으로, 대부분 항목에서 60% 이상의 채택률을 보이고 있습니다. 특히, 팀장의 기술 이해도 (95%), 개발 배포 및 운영(CI/CD, 80%), 사내 지식 공유 플랫폼(70%) 등의 항목은 높은 응답을 보였습니다. 다만, 글로벌 기업에서 주로 도입하는 개발자 레벨제도와 경력 관리 (25%), 개발자 관계(DevRel) 활동(28%)은 상당히 낮았습니다. 앞으로 모든 IT 기업에서 개발자 전용 커리어 제도 및 외부 개발자 지원 같은 개발자 관계 활동에 부족한 부분이 더 보완되어야 하겠습니다.

여기서 끝나면 너무 서운하겠죠. 아무래도 데이터에서 평균의 함정이 있는 것 같아서, 응답 기업을 좀 더 세분화해서 분석해 보았습니다. 기업 분류는 원래 설문에는 포함되어 있지 않았습니다만, 제가 각 회사 이름을 일일이 검색해서 다음과 같이 나누었습니다.

중소 기업(88개)은 업력이 10년 이상된 SI/제조/SW 개발업체, 스타트업(73개)은 업력이 10년 이하 소규모 기업, 인터넷 기업(35개)은 중견 IT 기업 및 시리즈 C 이상의 스타트업, 대기업(28개)은 재벌 및 그 계열사, 그리고 게임 업체(23개)로 나누었습니다.

##### 중소 IT기업 – 클라우드 및 SaaS 솔루션 도입을 통해 부족한 개발 문화 보완

중소 IT 기업의 경우, 팀장의 기술 이해도 (90%), 개발 배포 및 운영(CI/CD, 65%)를 제외하고, 모두 평균 보다 낮은 결과를 보여 줍니다. 아무래도 중소 IT 기업은 자본이 여유롭지 않고, 지속적인 인재 유출이 일어나다 보니 개발 자산을 축적하는데 어려움을 겪는 것 같습니다. 이럴때는 소프트웨어 서비스(SaaS)를 이용해서 문제를 해결해야 합니다. 코딩 테스트(32%, 코딜리티, 해커랭크, 프로그래머스), 코드 리뷰 (35%, Amazon CodeGuru), 코드 레포지터리(45%, Github), 지식 공유 플랫폼(46%, 슬랙, 잔디, 노션) 등에 바로 활용해 볼 수 있는 다양한 SaaS 서비스들이 있습니다.

개발 환경(41%)은 아무래도 긴 업력으로 인해 기술 부채가 많이 쌓여 있는 경우가 있는데, 클라우드 환경으로 빠르게 이전하면서 변화를 꾀하는 것이 상당히 도움이 됩니다. 또한, 개발 장비(44%) 같은 경우도 리스(Lease) 형식으로 구매를 하면 필요에 따라 개발자가 원하는 장비로 언제나 교체가 가능합니다. 대개 중소 기업 경영자들은 유형 자산에만 투자하는 경향이 많은데, 핵심 비지니스에 집중을 하기 위해서 약간의 비용이 더 추가되더라도 클라우드 이전, SaaS 도입, 장비 리스와 같은 아웃소싱을 통해 무형의 기업 문화 자산을 확보 해야 합니다.

##### 스타트업 – 협업 중심 개발 문화, 이직 시 속도와 성장이 더 중요한 점 고려

작은 규모의 기업이라도 업력이 10년 이하의 스타트업은 전혀 다른 양상을 보여줍니다. 대부분 평균 이상의 응답율을 보여 주고 있으며, 좋은 문화를 많이 가지고 있습니다. 특히, 코드 및 지식 공유(74%), 코드 및 지식 공유(74%), 자율적인 개발장비 선택 (69%), 개발 과정의 코드 리뷰(68%) 등 밀접한 협업 방식에 큰 방점을 두고 있는 것을 알 수 있습니다.

다만, 상대적으로 추천/소개를 통해 개발자 채용이 많이 이뤄지다 보니 채용시 코딩 테스트 활용도(58%)가 좀 낮고, 초기 제품 개발에 집중하다 보니 개발 환경 선택의 자율도(60%)가 조금 낮은 경향이 보입니다. 속도가 생명인 스타트업에서 오버 엔지니어링은 독약이긴죠. 스타트업 기업을 선택하시는 분들은 이런 문화적 특성을 잘 고려하셔야 할 것 같습니다.

##### 인터넷 기업 – 안정적인 개발 문화지만 개발 직군 우대 정책에 더 신경써야

흔히 네카라쿠베당토 그리고 몰두센 등 인기 IT 기업들이 몰려 있는 인터넷 기업 집단 역시 평균을 훨씬 상회하는 좋은 개발자 문화를 가지고 있습니다. 대부분 항목에서 70% 이상 90%에 육박하는 응답률을 보여 주고 있습니다. 사내 지식 공유 (94%), 코딩 테스트 (88%), 배포/관리 (88%), 코드 리뷰(84%) 등 상당히 안정적인 개발 지원 환경을 가지고 있는 것으로 파악됩니다. 특히, 개발자 관계(DevRel) 활동(60%)을 하는 빈도가 높고, 덕분에 채용을 위한 기술 블로그 및 컨퍼런스 같은 외부 기술 공유 활동도 활발합니다.

다만, 회사 규모가 커져서 다른 직군과의 형평성 때문인지 상대적으로 자율적인 개발 장비 선택(52%)이 제한되어 있다는 점은 아쉽습니다. 개발자 레벨 및 경력 관리 (32%)도 상대적으로 높지만 글로벌 오피스가 있는 일부 대형 스타트업 및 중견 인터넷 기업만 한정되어 있는데요. 이제는 글로벌 기업과 경쟁하고 어느 정도 여력이 되는 회사들이니까 빠르게 도입해 주세요.

##### 게임 업체 – 정보 공유는 활발하나 팀 사일로 해소 및 코드 리뷰 강화 필요

게임 회사가 상당히 많은 것이 우리 나라 IT 기업 특성 중 하나입니다. 게임 업체만 따로 뽑아서 비교를 해보니 평균적인 개발 문화를 가지고 있으며, 상대적으로 지식 공유 플랫폼 (77%), 개발자 관계 활동(43%) 등은 활발한 것으로 보입니다. 사실, 게임 업계에는 넥슨 개발자 컨퍼런스(NDC) 같은 업계를 다 아우르는 공유 문화가 있는 것은 특이한 점이기도 하지요.

다만, 게임은 스튜디오 단위로 타이틀을 주기적으로 만들고 있기 때문에, 회사 내 코드 공유 (51%), API 연동 (51%)등이 활발하지 않은 것으로 보입니다. 게임 기획이라는 장르가 개발자 기여 로드맵(51%)이 낮은 것도 이해할만 합니다. 코드 리뷰 및 테스트(42%)에 대한 응답은 상대적으로 더 낮은편인데, 짧은 게임 출시 주기에 따른 크런치 타임이 많아서 리뷰할 여유가 부족한 건지는 잘 모르겠네요. 이 부분은 보완해야할 필요가 있겠습니다.

##### 대기업 – 개발자 채용은 늘리고 있으나 내부 개발 문화 경직성 개선해야

최근 몇년 사이에 재벌 대기업 및 계열사의 디지털 전환 수요가 확대 되면서 개발자 채용이 확대되고 있는 추세입니다. 기존 인터넷 기업 출신들이 임원으로 이동한 많은 대기업들도 많습니다. SI 보다는 인-하우스 개발을 선호하면서, 프로세스를 중요시 하는 대기업 문화적 특성 탓에 코딩 테스트 도입(77%), 사내 CI/CD (88%), 지식 공유 플랫폼 (69%) 정도는 상대적으로 잘 구비되어 있습니다.

다만, 그 외 항목들은 모두 평균 이하를 보이고 있습니다. 개발자 채용 및 조직 세팅은 하고 있는데, 그에 따라 와야 하는 문화는 아직 전반적으로 부족하다는 것을 보여 주고 있습니다. 개발 환경의 경직성(18%)이나 개발 기여 로드맵(22%)의 자율성이 상당히 부족하여, 개발자들이 수동적인 업무를 하고 있음이 확연히 드러납니다.

이런 경우, 개발자 관계(DevRel) 활동(23%)이 독이 될 수도 있습니다. “좋다고 해서 들어와 보니 아니더라.” 이런 이야기 들을 수 밖에 없으니까요. 따라서, 이들 대기업의 DevRel 조직은 외부가 아니라 내부 개발 문화를 가꾸는데 집중해야 할 것으로 보입니다.

##### 추가 개선 사항 – 개발자는 더 많은 교육 기회와 도전적인 과제를 원한다

본 설문 조사에서는 “이것만은 빼 먹으면 안되죠.“라는 선택 응답 항목이 있었는데요. 대부분의 응답은 개인 성장 및 교육 지원에 대한 것이었습니다. 구체적으로, 업무 시간에 기술 스터디(스킬업) 및 외부 컨퍼런스 참여 허용, 자격증 취득 비용 및 도서 구매 지원, 해외 자료 (오라일리, 논문 사이트) 구독 및 해외 컨퍼런스 참여 기회 제공, 대외 활동 장려(외부 커뮤니티 활동, 외부 발표 및 오픈소스 참여 권장)와 같은 다양한 응답이 주류를 이루었습니다.

제가 12개 설문 항목을 선정 할 때, 개발직군은 기술을 다루기 때문에 기술적 성장은 당연히 포함되어 있으리라 생각하고 뺐는데요. 이런 응답이 많다는 것은 여전히 업무시간에는 일만 하고, 남는 시간에 공부를 하라는 회사들이 상당이 많다는 것을 의미하는 것이라 마음이 좀 아픕니다. 다음 조사에는 “13. 개발 지식 학습 및 성장 지원 – 업무로서 학습 기회 부여, 스터디 및 커뮤니티, 또는 외부 지식 공유 활동을 장려한다.” 항목을 꼭 넣어야 겠습니다. (개발자 학습 및 성장 지원이 부족한 회사들은 꼭 보완을 해주세요.)

또한, 회사에서 개인 프로젝트 지원, 제품 운영과 별도의 고도화 프로젝트 추가, 도전적인 기술적 과제들 등 실험적인 기술 중요하게 응답을 했습니다. 구글의 20% 프로젝트 같은 제도가 필요한 이유입니다. 예를 들어, 제가 개발 조직 매니저로 있을 시절에 팀원들이 연초에 연간 계획을 세울 때, 70%는 본인의 주 업무, 20%는 도전 과제(혹은 실험), 그리고 10%는 자기 계발에 할당하도록 했습니다. 다른 개발 팀장들에게도, 팀내에 항상 20%의 버퍼를 두라고 했습니다. 즉, 팀원 10명 중 적어도 2명은 놀고(?) 있어야 한다는 이야기죠. 비현실적인 것처럼 보이지만, 개인 학습을 지원하고 실험과 실패를 용인하는 문화를 가진 IT 기업들이 성공하고 있습니다.

##### 좋은 개발 문화를 가진 회사는 어디?

이 조사를 시작할 때는 실용적 엔지니어 테스트(2021)와 비교해서, 점수 분포와 상위 점수를 받은 기업들을 공개하고 싶었는데요. 우선 점수 분포에 대해 몇 가지 항목이 조금은 다르지만 거의 비슷하기 때문에 한번 비교를 해보았습니다. 해외의 경우, 11점이상이 50%으로 상향 평준화 되어 있는 반면 국내 기업은 점수별로 골고루 나눠져 있고, 어느 정도 정규 분포를 그리고 있습니다. (만약 다음 조사를 한다면, 꼭 상향 평준화 되었으면 좋겠네요.)

해외와 국내의 개발자 문화 응답 분포 차이

이제 모두가 궁금한 총 10점 이상 받은 업체들을 알아보겠습니다. 단, 본 조사에 응답한 재직자의 회사만 선택한 것이며, 한 명만 응답한 기업은 제외하고, 적어도 3명 이상이 응답한 회사 중에서 50% 이상이 동의한 항목 만을 고려했다는 점 다시 한번 말씀드립니다. (즉, 응답 안한 기업 재직자가 속한 업체 중 우수한 개발 문화를 가진 곳도 있을 것입니다.)

- 12점 – 카카오, 라인플러스, 우아한형제들, 컴투스, 업스테이지 등

- 11점 – 네이버, 엔에이치엔, 하이퍼커넥트, 데브시스터즈, 크몽, 에이비일팔공 등

- 10점 – 카카오뱅크, 크래프톤, 안랩, 당근마켓, 드림어스컴퍼니, 마이리얼트립, 원티드랩 등

11점 받은 기업들은 편차가 조금 있지만, 대체적으로 개발자 레벨링 및 경력 제도가 없다고 답했고, 10점 받은 기업들은 기업 분류에 따라 특성이 조금씩 달랐지만, 개발자 관계(DevRel) 활동이 부족하고 자율적인 개인 장비/팀 개발 환경 선택이 어렵다는 항목이 제법 많았습니다.

상위 점수를 기록한 기업들의 응답 항목 분포도

자! 어떻게 보셨나요? 이 글이 여러분의 회사의 개발 문화에 대해 한번 생각해 보시면서, 개선할 점을 찾는데 도움이 되셨다면 좋겠네요. 저도 주요 IT 기업 별로 개발 문화의 상황을 파악하는데 도움이 많이 되었습니다. 제가 선정한 각 항목에 대한 더 자세한 것은 “훌륭한 개발 문화의 이면“이라는 시리즈를 봐주시면 바랍니다.

2009년쯤 이 블로그가 매우 흥할때(?), 개발자 채용 정보를 블로그에 올려서 방문자들이 볼 수 있게 해주는 기능을 잠시 운영했었습니다. 당시, 채용 정보 등록 받을 때 조엘 테스트를 넣게했던 기억이 나는데요. 우리 나라 개발자 채용 사이트에도 이런 항목을 넣어서 구직자가 그 회사의 개발 문화를 어느 정도 알게 하는 것도 필요할 것 같네요.

차니 블로그 ‘개발자 구인’ 정보 입력 양식 (2009)

그래서, 개발 문화 설문 조사 양식은 마감하지 않고, 그대로 두려고 합니다. 아직 응답 안 하신 분들은 계속 해주시면 연말 즈음에 변화된 정보가 있으면 이 글에 추가로 업데이트 해 보겠습니다. 마지막으로 이번 설문 조사에 도움을 주신 원티드랩에 감사드립니다.

연재 목차

※ Disclaimer- 본 글은 개인적인 의견일 뿐 제가 재직했거나 하고 있는 기업의 공식 입장을 대변하거나 그 의견을 반영하는 것이 아닙니다. 사실 확인 및 개인 투자의 판단에 대해서는 독자 개인의 책임에 있으며, 상업적 활용 및 뉴스 매체의 인용 역시 금지함을 양해해 주시기 바랍니다. (The opinions expressed here are my own and do not necessarily represent those of current or past employers. Please note that you are solely responsible for your judgment on checking facts for your investments and prohibit your citations as commercial content or news sources.)

- 이 글의 댓글 일부는 Webmention 도구를 이용하여, 소셜 미디어 공유 반응(Comments, Like, Tweet)을 수집한 것입니다.

---

## 13. [[Modern Java] 람다 표현식(Lambda Expression)](https://dev-kani.tistory.com/38)
> 생성: 2022-07-24

프로그래밍/Java

- 아래 내용은 '모던 자바 인 액션'을 읽고 정리한 글로 책 내용의 순서를 따라간다.

- 상세한 내용이나 예시는 책과 상이할 수 있다.

- 예제 코드에서 사용되고 있는 스펙 

### 람다(Lambda)란?

-  

-   

-  

-  

#### Q. 퀴즈-1) 람다 문법

- 앞에서 설명한 람다 규칙에 맞지 않는 람다 표현식을 고르시오. 

#### A. 정답

- 정답 

#### 람다 예제

-  

-  

-  

### 어디에, 어떻게 람다를 사용할까?

- 함수형 인터페이스(Functional Interface)

- 함수 디스크립터(Function Descriptor)

- 위의 내용은 따로 포스팅해서 다룰 예정이다.

### 람다 활용 : 실행 어라운드 패턴

- 자원 처리 (예를 들면 데이터베이스의 파일 처리)에 사용하는 순환 패턴(recurrent pattern)은 자원을 열고, 처리한 다음에, 자원을 닫는 순서로 이루어진다.

- 설정(setup)과 정리(cleanup) 과정은 대부분 비슷하다.

- 아래 그림과 같은 형식의 코드를 실행 어라운드 패턴(execute around pattern)이라고 부른다.

```plain text
public String processFile() throw IOException {
        try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
                return br.readLine(); // <- 실제 필요한 작업을 하는 행이다.
        }
}
```

#### 1단계 : 동작 파라미터화를 기억하라

- 현재 코드는 파일에서 한 번에 한 줄만 읽을 수 있다.

- 한 번에 두 줄을 읽거나 가장 자주 사용되는 단어를 반환하려면 어떻게 해야 할까?

- 기존의 설정, 정리 과정은 재사용하고 processFile 메서드만 다른 동작을 수행하도록 명령할 수 있다면 좋을 것이다.

- 여기서는 processFile의 동작을 파라미터화하면 된다.

- processFile 메서드가 한 번에 두 행을 읽게 하려면 우선 BufferedReader를 인수로 받아서 String을 반환하는 람다가 필요하다.

```plain text
String result = processFile((BufferedReader br) -> br.readLine() + br.readLine());
```

#### 2단계 : 함수형 인터페이스를 이용해서 동작 전달

- 함수형 인터페이스 자리에 람다를 사용할 수 있다.

```plain text
@FunctionalInterface
public interface BufferedReaderProcessor {
        String process(BufferedReader b) throws IOException;
}
```

- 정의한 인터페이스를 processFile 메서드의 인수로 전달할 수 있다.

```plain text
public String processFile(BufferedReaderProcessor p) throws IOException {
        ...
}
```

#### 3단계 : 동작 실행

- 이제 BufferedReaderProcessor에 정의된 process 메서드의 시그니처 (BufferedReader → String)와 일치하는 람다를 전달할 수 있다.

- 따라서 processFile 바디 내에서 BufferedReaderProcessor 객체의 process를 호출할 수 있다.

```plain text
public String processFile(BufferedReaderProcessor p) throws IOException {
        try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {
                return p.process(br);
        }
}
```

#### 4단계 : 람다 전달

```plain text
// 한 행을 처리하는 코드다.
String oneLine = processFile((BufferedReader br) -> br.readLine());

// 두 행을 처리하는 코드다.
String twoLines = processFile((BufferedReader br) -> br.readLine() + br.readLine());
```

### 함수형 인터페이스 사용

- 별도 포스팅

### 형식 검사, 형식 추론, 제약

#### 형식 검사

- 람다가 사용되는 컨텍스트(context)를 이용해서 람다의 형식(type)을 추론할 수 있다.

- 어떤 컨텍스트에서 기대되는 람다 표현식의 형식을 대상 형식(target type)이라고 부른다.

```plain text
List<Apple> heavierThan150g = filter(inventory, (Apple apple) -> apple.getWeight() > 150);
```

- 위 코드의 형식 확인 과정을 보여준다. 

- 람다 표현식이 예외를 던질 수 있다면 추상 메서드도 같이 예외를 던질 수 있도록 throws로 선언해야 한다.

#### 같은 람다, 다른 함수형 인터페이스

- 대상 형식(target typing)이라는 특징 때문에 같은 람다 표현식이더라도 호환되는 추상 메서드를 가진 다른 함수형 인터페이스로 사용될 수 있다.

```plain text
Comparator<Apple> c1 = (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());
ToIntBiFunction<Apple, Apple> c2 = (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());
BiFunction<Apple, Apple, Integer> c3 = (Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight());
```

-  

-  

#### Q. 퀴즈-2) 형식 검사 문제, 다음 코드를 컴파일할 수 없는 이유는?

-  

#### A. 정답

-  

#### 형식 추론

- 자바 컴파일러는 람다 표현식이 사용된 컨텍스트(대상 형식)를 이용해서 람다 표현식과 관련된 함수형 인터페이스를 추론한다.

- 즉, 대상 형식을 이용해서 함수 디스크립터를 알 수 있으므로 컴파일러는 람다의 시그니처도 추론할 수 있다.

- 결과적으로 컴파일러는 람다 표현식의 파라미터 형식에 접근할 수 있으므로 람다 문법에서 이를 생략할 수 있다.

- 즉, 자바 컴파일러는 다음처럼 람다 파라미터 형식을 추론할 수 있다.

- 여러 파라미터를 포함하는 람다 표현식에서는 코드 가독성 향상이 더 두드러진다.

- 상황에 따라 명시적으로 형식을 포함하는 것이 좋을 때도 있고 형식을 배제하는 것이 가독성을 향상시킬 때도 있다.

- 어떤 방법이 좋은지 정해진 규칙은 없다.

- 개발자 스스로 어떤 코드가 가독성을 향상시킬 수 있는지 결정해야 한다. 

#### 지역 변수 사용

- 람다 표현식에서는 익명 함수가 하는 것처럼 자유 변수(free variable, 파라미터로 넘겨진 변수가 아닌 외부에서 정의된 변수)를 활용할 수 있다.

- 이와 같은 동작을 람다 캡처링(capturing lambda)이라고 부른다.

```plain text
int portNumber = 1337;
Runnable r = () -> System.out.println(portNumber);
```

##### 지역 변수의 제약

- 인스턴스 변수는 힙에 저장되는 반면 지역 변수는 스택에 위치한다.

- 람다에서 지역 변수에 바로 접근할 수 있다는 가정하에 람다가 스레드에서 실행된다면 변수를 할당한 스레드가 사라져서 변수 할당이 해제되었는데도 람다를 실행하는 스레드에서는 해당 변수에 접근하려 할 수 있다.

- 따라서 자바 구현에서는 원래 변수에 접근을 허용하는 것이 아니라 자유 지역 변수의 복사본을 제공한다.

- 따라서 복사본의 값이 바뀌지 않아야 하므로 지역 변수에는 한 번만 값을 할당해야 한다는 제약이 생긴 것이다.

- 또한 지역 변수의 제약 때문에 외부 변수를 변화시키는 일반적인 명령형 프로그래밍 패턴(병렬화를 방해하는 요소)에 제동을 걸 수 있다.

- 클로저(closure) 

### 메서드 참조(Method References)

- Java 8의 새로운 기능이다.

```plain text
inventory.sort((Apple a1, Apple a2) -> a1.getWeight().compareTo(a2.getWeight()));
```

- 위와 같이 람다로 표현된 코드가 있을 때 java.util.Comparator.comparing 메서드를 활용해서 다음과 같이 표현할 수 있다.

```plain text
inventory.sort(comparing(Apple::getWeight));
```

- 메서드 참조는 특정 메서드만 호출하는 람다의 축약형이라고 생각할 수 있다.

- 메서드 참조를 이용하면 기존 메서드 구현으로 람다 표현식을 만들 수 있다.

- 이때 명시적으로 메서드명을 참조함으로써 가독성을 높일 수 있다.

---

## 14. [if statement - Use Java lambda instead of 'if else' - Stack Overflow](https://stackoverflow.com/questions/49857232/use-java-lambda-instead-of-if-else)
> 생성: 2022-07-25

_(본문 없음)_

---

## 15. [Java 8 함수형 인터페이스 (Functional Interface)](https://bcp0109.tistory.com/313)
> 생성: 2022-07-25

### Overview

함수형 인터페이스란 1 개의 추상 메소드를 갖는 인터페이스를 말합니다.

Java8 부터 인터페이스는 기본 구현체를 포함한 디폴트 메서드 (default method) 를 포함할 수 있습니다.

여러 개의 디폴트 메서드가 있더라도 추상 메서드가 오직 하나면 함수형 인터페이스입니다.

자바의 람다 표현식은 함수형 인터페이스로만 사용 가능합니다.

함수형 인터페이스는 위에서도 설명했듯이 추상 메서드가 오직 하나인 인터페이스를 의미합니다.

추상 메서드가 하나라는 뜻은 default method 또는 static method 는 여러 개 존재해도 상관 없다는 뜻입니다.

그리고 @FunctionalInterface 어노테이션을 사용하는데, 이 어노테이션은 해당 인터페이스가 함수형 인터페이스 조건에 맞는지 검사해줍니다.

@FunctionalInterface 어노테이션이 없어도 함수형 인터페이스로 동작하고 사용하는 데 문제는 없지만, 인터페이스 검증과 유지보수를 위해 붙여주는 게 좋습니다.

#### 1.1. Functional Interface 만들기

```plain text
@FunctionalInterface
interface CustomInterface<T> {
    // abstract method 오직 하나
    T myCall();

    // default method 는 존재해도 상관없음
    default void printDefault() {
        System.out.println("Hello Default");
    }

    // static method 는 존재해도 상관없음
    static void printStatic() {
        System.out.println("Hello Static");
    }
}
```

위 인터페이스는 함수형 인터페이스입니다.

default method, static method 를 넣어도 문제 없습니다.

어차피 함수형 인터페이스 형식에 맞지 않는다면 @FunctionalInterface 이 다음 에러를 띄워줍니다.

#### 1.2. 실제 사용

```plain text
CustomInterface<String> customInterface = () -> "Hello Custom";

// abstract method
String s = customInterface.myCall();
System.out.println(s);

// default method
customInterface.printDefault();

// static method
CustomFunctionalInterface.printStatic();
```

함수형 인터페이스라서 람다식으로 표현할 수 있습니다.

String 타입을 래핑했기 때문에 myCall() 은 String 타입을 리턴합니다.

마찬가지로 default method, static method 도 그대로 사용할 수 있습니다.

위 코드를 실행한 결과값은 다음과 같습니다.

```plain text
Hello Custom
Hello Default
Hello Static
```

### 2. Java 에서 기본적으로 제공하는 Functional Interfaces

매번 함수형 인터페이스를 직접 만들어서 사용하는 건 번거로운 일입니다.

그래서 Java 에서는 기본적으로 많이 사용되는 함수형 인터페이스를 제공합니다.

기본적으로 제공되는 것만 사용해도 웬만한 람다식은 다 만들 수 있기 때문에 개발자가 직접 함수형 인터페이스를 만드는 경우는 거의 없습니다.

#### 2.1. Predicate

```plain text
@FunctionalInterface
public interface Predicate<T> {
    boolean test(T t);
}
```

Predicate 는 인자 하나를 받아서 boolean 타입을 리턴합니다.

람다식으로는 T -> boolean 로 표현합니다.

#### 2.2. Consumer

```plain text
@FunctionalInterface
public interface Consumer<T> {
    void accept(T t);
}
```

Consumer 는 인자 하나를 받고 아무것도 리턴하지 않습니다.

람다식으로는 T -> void 로 표현합니다.

소비자라는 이름에 걸맞게 무언가 (인자) 를 받아서 소비만 하고 끝낸다고 생각하면 됩니다.

#### 2.3. Supplier

```plain text
@FunctionalInterface
public interface Supplier<T> {
    T get();
}
```

Supplier 는 아무런 인자를 받지 않고 T 타입의 객체를 리턴합니다.

람다식으로는 () -> T 로 표현합니다.

공급자라는 이름처럼 아무것도 받지 않고 특정 객체를 리턴합니다.

#### 2.4. Function

```plain text
@FunctionalInterface
public interface Function<T, R> {
    R apply(T t);
}
```

Function 은 T 타입 인자를 받아서 R 타입을 리턴합니다.

람다식으로는 T -> R 로 표현합니다.

수학식에서의 함수처럼 특정 값을 받아서 다른 값으로 반환해줍니다.

T 와 R 은 같은 타입을 사용할 수도 있습니다.

#### 2.5. Comparator

```plain text
@FunctionalInterface
public interface Comparator<T> {
    int compare(T o1, T o2);
}
```

Comparator 은 T 타입 인자 두개를 받아서 int 타입을 리턴합니다.

람다식으로는 (T, T) -> int 로 표현합니다.

#### 2.6. Runnable

```plain text
@FunctionalInterface
public interface Runnable {
    public abstract void run();
}
```

Runnable 은 아무런 객체를 받지 않고 리턴도 하지 않습니다.

람다식으로는 () -> void 로 표현합니다.

Runnable 이라는 이름에 맞게 "실행 가능한" 이라는 뜻을 나타내며 이름 그대로 실행만 할 수 있다고 생각하면 됩니다.

#### 2.7. Callable

```plain text
@FunctionalInterface
public interface Callable<V> {
    V call() throws Exception;
}
```

Callable 은 아무런 인자를 받지 않고 T 타입 객체를 리턴합니다.

람다식으로는 () -> T 로 표현합니다.

Runnable 과 비슷하게 Callable 은 "호출 가능한" 이라고 생각하면 좀 더 와닿습니다.

##### Supplier vs Callable

Supplier 와 Callable 은 완전히 동일합니다.

아무런 인자도 받지 않고 특정 타입을 리턴해줍니다.

둘이 무슨 차이가 있을까..?

사실 그냥 차이가 없다고 생각하시면 됩니다.

단지 Callable 은 Runnable 과 함께 병렬 처리를 위해 등장했던 개념으로서 ExecutorService.submit 같은 함수는 인자로 Callable 을 받습니다.

### 3. 두 개의 인자를 받는 Bi 인터페이스

특정 인자를 받는 Predicate, Consumer, Function 등은 두 개 이상의 타입을 받을 수 있는 인터페이스가 존재합니다.

### 4. 기본형 특화 인터페이스

지금까지 확인한 함수형 인터페이스를 제네릭 함수형 인터페이스라고 합니다.

자바의 모든 형식은 참조형 또는 기본형입니다.

- 참조형 (Reference Type) : Byte, Integer, Object, List

- 기본형 (Primitive Type) : int, double, byte, char

Consumer<T> 에서 T 는 참조형만 사용 가능합니다.

Java 에서는 기본형과 참조형을 서로 변환해주는 박싱, 언박싱 기능을 제공합니다.

- 박싱 (Boxing) : 기본형 -> 참조형 (int -> Integer)

- 언박싱 (Unboxing) : 참조형 -> 기본형 (Integer -> int)

게다가 개발자가 박싱, 언박싱을 신경쓰지 않고 개발할 수 있게 자동으로 변환해주는 오토박싱 (Autoboxing) 이라는 기능도 제공합니다.

예를 들어 List<Integer> list 에서 list.add(3) 처럼 기본형을 바로 넣어도 사용 가능한 것도 오토박싱 덕분입니다.

하지만 이런 변환 과정은 비용이 소모되기 때문에, 함수형 인터페이스에서는 이런 오토박싱 동작을 피할 수 있도록 기본형 특화 함수형 인터페이스 를 제공합니다.

IntPredicate, LongPredicate 등등 특정 타입만 받는 것이 확실하다면 기본형 특화 인터페이스를 사용하는 것이 더 좋습니다.

아래에서 소개하는 인터페이스 외에 UnaryOperator 나 Bi 인터페이스에도 기본형 특화를 제공합니다.

#### 4.1 Predicate (T -> boolean)

기본형을 받은 후 boolean 리턴

- IntPredicate

- LongPredicate

- DoublePredicate

#### 4.2. Consumer (T -> void)

기본형을 받은 후 소비

- IntConsumer

- LongConsumer

- DoubleConsumer

#### 4.3. Function (T -> R)

기본형을 받아서 기본형 리턴

- IntToDoubleFunction

- IntToLongFunction

- LongToDoubleFunction

---

## 16. [Java 8 람다 표현식 자세히 살펴보기 | Devlog in the SKY](https://skyoo2003.github.io/post/2016/11/09/java8-lambda-expression/)
> 생성: 2022-07-25

2010년도에 ‘Project Lambda’ 라는 프로젝트로 진행되어 Java 8 에 공식 릴리즈가 되었다. 기존의 Java 언어에 어떻게 함수형 프로그래밍을 녹여내었는지 좀 더 자세히 정리하고자 한다.

#### 함수형 프로그래밍 간략하게 알아보기

자바의 람다식을 소개하기 전에 함수형 프로그래밍에 대해서 간략하게라도 알아볼 필요가 있다. (람다 대수에 근간을 두는 함수형 프로그래밍은 패러다임이고, 람다 표현식은 이를 나타낸다고 볼 수 있기 때문!)

함수형 프로그래밍은 함수의 입력만을 의존하여 출력을 만드는 구조로 외부에 상태를 변경하는 것을 지양하는 패러다임으로 부작용(Side-effect) 발생을 최소화 하는 방법론이라 할 수 있다. 함수형 프로그래밍에서는 다음의 조건을 만족시켜야 하는데 먼저 이것부터 정리해보자.

- 순수한 함수 (Pure Function)

부작용 (Side-effect)가 없는 함수로 함수의 실행이 외부의 상태를 변경시키지 않는 함수를 의미한다. 순수한 함수는 멀티 쓰레드 환경에서도 안전하고, 병렬처리 및 계산이 가능하다. 오직 입력에 의해서만 출력이 정해지고, 환경이나 상태에 영향을 받아서는 안된다는 의미이다.

- 익명 함수 (Annonymous Function)

이름이 없는 함수를 정의할 수 있어야 한다. 이러한 익명 함수는 대부분의 프로그래밍 언어에서 ‘람다식’으로 표현하고 있으며, 이론적인 근거는 람다 대수에 있다.

- 고계 함수 (Higher-order Function)

함수를 다루는 상위의 함수로 함수형 언어에서는 함수도 하나의 값으로 취급하고, 함수의 인자로 함수를 전달할 수 있는 특성이 있다. 이러한 함수를 일급 객체 (a.k.a 일급 함수) 로 간주한다.

그렇다면, 자바에서는 함수형 프로그래밍을 어떻게 언어 차원에서 지원할 수 있었는지 간략하게 알아보자.

자바에는 함수의 개념이 없다. (자바의 메소드는 일급 함수가 아니므로, 다른 메소드로 전달할 수 없다. 자바에는 모든 것이 객체다. 메소드는 객체의 행위를 정의하고 객체의 상태를 변경한다.) 이런 이유로 기존의 자바 언어 체계에서는 함수형 언어를 언어 차원에서 지원하지는 못하였다. (함수형 프로그래밍의 조건을 만족하도록 구현한다면 기존에도 가능하다고 할 수 있겠다.)

떄문에, Java8 에서 함수형 인터페이스(단 하나의 메소드만이 선언된 인터페이스)라는 개념을 도입하게 되었고, 함수형 인터페이스의 경우, 람다식으로 표현이 가능할 수 있게 제공하였다.

Java8에서 함수형 인터페이스라는 개념과 람다식 표현을 통해 입력에 의해서만 출력이 결정되도록 ‘순수한 함수’를 표현할 수 있게 되었고, 람다식으로 표현함으로써 ‘익명 함수’를 정의할 수 있게 되었고, 함수형 인터페이스의 메소드에서 또다른 함수형 인터페이스를 인자로 받을 수 있도록 하여 ‘고계 함수’를 정의할 수 있게 되었다. 즉, 함수형 프로그래밍 언어의 조건을 만족시킬 수 있게 되었다고 할 수 있다.

```java
public interface Functional1 {
  boolean accept();
}

public interface Functional2 {
  boolean accept();
  default boolean reject() { return !accept(); }
}

@FunctionalInterface
public interface Functional3 {
  boolean accept();
}

public interface NotFunctional {
  boolean accept();
  boolean reject();
}

```

함수형 인터페이스가 무엇인지 예제를 통해 간략히 알아보면, Functional1, 2, 3는 모두 함수형 인터페이스를 만족한다. 특이한 점이 Functional3 인터페이스의 경우, @FunctionalInterface 어노테이션을 붙여주었는데, 이는 컴파일러에게 명시적으로 함수형 인터페이스임을 알려주는 역할을 하고, 해당 인터페이스가 함수형 인터페이스 명세를 어기면 컴파일러 에러를 발생시켜 준다.

#### 람다 표현식 자세히 알아보기

자바에서 기본적인 람다식 구조는 아래와 같다.

```java
(int a, int b) -> {return a + b} // 매개변수 -> 함수 로직 (+@ 리턴)
```

정리해보자면 아래와 같다.

- 단순한 람다 구문의 경우, 람다 구분에 중괄호가 없을 수도 있다.

- return 이 없을 수도 있다.

- 매개변수에는 타입을 명시하지 않아도 된다. (타입 추론)

- 람다식 문법을 컴파일러가 익명 클래스로 변환한다. 즉, 함수형 인터페이스를 컴파일러가 구현하도록 위임하는 형태라 볼 수 있다

```java
() -> {}                     // No parameters; result is void
() -> 42                     // No parameters, expression body
() -> null                   // No parameters, expression body
() -> { return 42; }         // No parameters, block body with return
() -> { System.gc(); }       // No parameters, void block body
}                          // Complex block body with returns
(int x) -> x+1             // Single declared-type parameter
(int x) -> { return x+1; } // Single declared-type parameter
(x) -> x+1                 // Single inferred-type parameter
x -> x+1                   // Parens optional for single inferred-type case
(String s) -> s.length()   // Single declared-type parameter
(Thread t) -> { t.start(); } // Single declared-type parameter
s -> s.length()              // Single inferred-type parameter
t -> { t.start(); }          // Single inferred-type parameter
(int x, int y) -> x+y      // Multiple declared-type parameters
(x,y) -> x+y               // Multiple inferred-type parameters
(final int x) -> x+1       // Modified declared-type parameter
(x, final y) -> x+y        // Illegal: can't modify inferred-type parameters
(x, int y) -> x+y          // Illegal: can't mix inferred and declared types

```

#### 람다 표현식 활용

위에서 자바의 함수형 프로그래밍과 람다 표현식에 대해서 자세하게 살펴보았고, 이번에는 람다의 구체적인 명세에 대해서 정리해보고자 한다. 람다식을 활용함에 있어 어떤 부분이 문법적인 제약이 있는지, 어떤 방법으로 활용될 수 있는지에 대해서 정리해보는 부분이라고 이해하면 좋다.

##### 파라미터에 행위 전달 (Parameterized Behaviors)

메소드에 사용할 데이터 혹은 변수와 행위를 같이 전달하게 하여 메소드의 행위 부분도 분리할 수 있을 것이다. 이를 통해 얻을 수 있는 장점은 아래 정도로 정리할 수 있을 것이다.

- 런타임에 행위를 전달 받아서 제어 흐름 수행 (cf. 전략 패턴)

- 메소드 단위의 추상화가 가능

- 함수형 언어의 고차 함수 (Higher-Order Function)

```java
public class Collections {
  ...
  public static <T> T max(Collection<? extends T> coll, Comparator<? super T> comp) {
    ...
  }
  ...
}

public class Fruit {
  public String name;
}

// AS-IS
Collections.max(fruits, new Comparator<Fruit> {
  @Override
  public int compare(Fruit o1, Fruit o2) {
      return o1.name.compareTo(o2.name);
  }
});

// TO-BE
Collections.max(fruits, (o1, o2) -> o1.name.compareTo(o2.name) ;

```

스프링 프레임워크에서 익명 클래스를 이용한 행위 파라미터를 적극적으로 활용해 ‘템플릿 콜백 패턴’ 디자인패턴으로 이미 유용하게 사용되던 기법이었고, 람다식으로 간결하게 사용할 수 있게 된 것이다.

##### 불변 변수 사용 (Immutable Free Variables)

자바에서 익명 클래스 + 자유 변수 포획으로 클로저를 가능하게 하였는데, 포획된 변수에는 명시적으로 final 지시자를 사용하도록 강제하였다. 람다식에서는 포획된 변수에 final 을 명시하지 않아도 되도록 변경되었지만 기존과 동일하게 포획된 변수는 변경할 수 없고, 변경하는 경우 컴파일 에러가 발생한다.

```java
new Thread(() -> System.out.println(counter)) // OK
new Thread(() -> System.out.println(counter++)) // Compile Error (Free variable is immutable!)

```

##### 상태 없는 객체 (Stateless Object)

클래스의 메소드(행위)에서 멤버 변수(상태)를 자유롭게 제어할 수 있다. 즉, 객체가 메소드를 호출하면 입력(Input)+상태(Properties)로부터 출력(Output)이 결정되기 때문에 Side-Effect가 발생할 수 있다. 함수 단위의 배타적 수행이 보장되지 않기 때문에 병렬 처리와 멀티 스레드 환경에서 여러 단점에 노출될 가능성이 있다.

반면에 람다식으로 표현하게 되면, 오로지 입력(Input)과 출력(Output)에 종속되어 있기 때문에 Side-Effect 가 발생하지 않는 것을 최대한 보장할 수 있게 된 것이다. 후술할 스트림 API 에서는 함수형 인터페이스를 최대한 활용해 병렬(Parallel) 처리를 어떻게 효과적으로 할 수 있는지 알아볼 예정이다.

##### Optional + Lambda 조합

java.util.Optional 이라는 클래스는 값이 있거나 없는 경우를 표현하기 위한 클래스로 map, filter, flatMap 등의 고차 함수를 가지고 있다. Optional의 고차 함수를 조합하여 간결하게 표현이 가능하며, 언제 발생할지 모르는 NullPointerException 의 두려움에 방어 로직으로부터 벗어날 수 있지 않을까 한다.

- ‘If (obj != Null)’ Null 체크로부터 해방

```java
// AS-IS
Member member = memberRepository.findById(1L);
Coord coord = null;
if (member != null) {
  if (member.getAddress() != null) {
    String zipCode = member.getAddress().getZipCode();
    if (zipCode != null) {
      coord = coordRepository.findByZipCode(zipCode)
    }
  }
}

// TO-BE
Optional<Member> member = memberRepository.findById(1L);
Coord coord = member.map(Member::getAddress)
    .map(address -> address.getZipCode())
    .map(zipCode -> coordRepository.findByZipCode(zipCode))
    .orElse(null)

```

- 비어 있는 객체 생성

```java
Optional<Member> member = Optional.empty();
```

- Null 허용하지 않는 객체 생성

```java
Optional<Member> member = Optional.of(memberRepository.findById(1L));
member.get() // NullPointerException !!!
```

- 값이 존재할 때, 특정 메소드 호출

```java
// AS-IS
Member member = memberRepository.findById(1L);
if (member != null) {
  System.out.println(member);
}

// TO-BE
Optional<Member> member = Optional.ofNullable(memberRepository.findById(1L));
member.ifPresent(System.out::println);

```

- 값 존재할 경우와 아닌 경우를 삼항 연산자로 표현하지 않아도 됨

```java
// AS-IS
Member member = memberRepository.findById(1L);
System.out.println(member != null ? member : new Member("Unknown"));

// TO-BE
Optional<Member> member = Optional.ofNullable(memberRepository.findById(1L));
member.orElse(new Member("Unknown")).ifPresent(System.out::println);

```

- 특정 조건을 만족하는 경우에만 특정 행위를 하고 싶을 경우

```java
// AS-IS
Member member = memberRepository.findById(1L);
if (member != null && member.getRating() != null && member.getRating() >= 4.0) {
  System.out.println(member);
}

// TO-BE
Optional<Member> member = Optional.ofNullable(memberRepository.findById(1L));
member.filter(m -> m.getRating() >= 4.0)
    .ifPresent(m -> System.out::println)

```

---

## 17. [Mapping JPA Entities into DTOs in Spring Boot Using MapStruct](https://auth0.com/blog/how-to-automatically-map-jpa-entities-into-dtos-in-spring-boot-using-mapstruct/)
> 생성: 2022-07-28

Spring Boot + MapStruct

Avoid boilerplate code by automatically mapping JPA entities into DTOs in Spring Boot and Java by harnessing MapStruct

In multi-layered architectures, data is usually represented differently at each layer. For example, this is what usually happens in client-server applications. In such architectures, communicating between layers may become cumbersome. This can be avoided by harnessing the DTO pattern, which involves defining simple classes to transfer data between layers, thus simplifying communication. The main issue that comes with this approach is that it requires writing a large amount of mapping code, which is an error-prone and tedious task. Thankfully, there is MapStruct, a Java library aimed at avoiding this boilerplate code by automating the mapping process as much as possible.

Firstly, you will dive into the DTO pattern and MapStruct. Then, you will see how to create a demo REST services application aimed at showing how to harness the DTO pattern with MapStruct in Spring Boot in Java.

#### What is a DTO?

Martin Fowler introduced the concept of a Data Transfer Object (DTO) as an object that carries data between processes in order to reduce the number of method calls.

The DTO pattern can be employed in many different ways, and as I have already shown, the most common approach to exploiting DTOs is to use them to transfer data between different layers of multi-layered architectures. For example, in client-server applications, they are especially useful when employed to send data to a client application, such as an Angular or React Single-Page Application (SPA). When contacted by the client, the server application collects all the requested data, stores it in a custom-defined DTO, and sends it back. This way, the client application can get all the desired data in a single API call. Plus, the server is sending only the minimum amount of data across the wire. You can also use DTOs as both input and output in method calls. For example, by using DTO objects you can define DAO (Data Access Object)-layer methods handling many parameters or return highly-structured data. As a consequence, you get a more concise class with a reduced number of required methods.

All these examples share the same major drawback, which is part of the DTO pattern itself. As mentioned earlier, the DTO pattern depends on mappers aimed at converting data into DTOs and vice versa. This involves boilerplate code and introduces overheads that might not be overlooked, especially when dealing with large data.

#### What is MapStruct?

MapStruct is a code generator tool that greatly simplifies the implementation of mappings between Java bean types based on a convention over configuration approach. The generated mapping code uses plain method invocations and thus is fast, type-safe, and easy to understand.

In other words, MapStruct is plugged into the Java compiler and can automatically generate mappers at build-time.

Let’s see how to integrate MapStruct into a Spring Boot and Java project to map JPA entities into DTOs with no extra effort.

#### Prerequisites

This is the list of all the prerequisites for the demo application you are going to build:

- Java >= 1.8

- Spring Boot 2.4.4

- MapStruct 1.4.2.Final

- Gradle >= 4.x or Maven 3.6.x

- MariaDB 10.x

#### Adding the Required Dependencies

First, you need to add mapstruct and mapstruct-processor to your project’s dependencies. The latter will be used by MapStruct to generate the mapper implementations during build-time.

If you are a Gradle >= 4.6 user, add these dependencies to your build.gradle file:

```plain text
dependencies {
    // ...
    implementation "org.mapstruct:mapstruct:1.4.2.Final"
    annotationProcessor "org.mapstruct:mapstruct-processor:1.4.2.Final"
}
```

For older versions (< 4.6), you need also the gradle-apt-plugin plugin:

```plain text
plugins {
    // ...
    id "net.ltgt.apt" version "0.21"
}

// ...

dependencies {
    // ...
    compile "org.mapstruct:mapstruct:1.4.2.Final"
    apt "org.mapstruct:mapstruct-processor:1.4.2.Final"
}
```

If you are a Maven user, add the following dependencies to your pom.xml file:

```plain text
<dependencies>
    <!-- ... -->
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>1.4.2.Final</version>
    </dependency>
</dependencies>

<!-- ... -->

<build>
    <plugins>
        <!-- ... -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.5.1</version>
            <configuration>
                <source>11</source> <!-- depending on your project. In this example, Java 11 is used -->
                <target>11</target> <!-- depending on your project. In this example, Java 11 is used -->
                <annotationProcessorPaths>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>1.3.1.Final</version>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

Besides a MapStruct dependency, a maven-compiler-plugin plugin must be also configured in your pom.xml file. In order to make the mapstruct-processor work, you need to add it to the annotationProcessorPaths section of the plugin configuration.

Now, you have all you need to start using MapStruct.

#### Defining the JPA Entities and Their DTOs

#### Importing the Database

The demo project you are going to see requires a MariaDB database. So, first, you need to set up a MariaDB instance. Then, you can import the mapstruct_demo.sql dump file located in the GitHub Repository supporting this article.

Now, you need to add a MySQL driver to your dependencies. You can achieve this by adding a mysql-connector-java dependency to your pom.xml file:

```plain text
<dependencies>
    <!-- ... -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>8.0.23</version>
    </dependency>
</dependencies>
```

Or to your build.gradle file, if you are a gradle user:

```plain text
dependencies {
    // ...
    compile "mysql:mysql-connector-java:8.0.23"
}
```

Lastly, you have to configure your Spring Boot application to make it connect to the just defined database. You can achieve this by adding the following lines to your project’s application.properties file:

```plain text
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/mapstruct_demo
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
```

The demo database is really simple and consists of only three entities, associated as follows:

> Note that MariaDB is chosen just for simplicity, the approach presented in this article is database-agnostic.

#### Defining the JPA Entities

Our model domain consists of three JPA entities: User, Author, Book and I recommend placing all your entities in the same package, e.g. com.mapstruct.demo.entities. You can be defined them as follows:

```plain text
@Getter
@Setter
@Entity
@Table(name = "user")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY, generator = "native")
    @Column
    private int id;

    @Basic
    @Column
    private String email;

    @Basic
    @Column
    private String password;

    @Basic
    @Column
    private String name;

    @Basic
    @Column
    private String surname;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "user_book",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "book_id")
    )
    private Set<Book> books = new HashSet<>();
}
```

```plain text
@Getter
@Setter
@Entity
@Table(name = "author")
public class Author {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY, generator = "native")
    @Column
    private int id;

    @Basic
    @Column
    private String name;

    @Basic
    @Column
    private String surname;

    @Basic
    @Column(name = "birth_date")
    @Temporal(TemporalType.DATE)
    private Date birthDate;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "author_book",
            joinColumns = @JoinColumn(name = "author_id"),
            inverseJoinColumns = @JoinColumn(name = "book_id")
    )
    private Set<Book> books = new HashSet<>();
}
```

```plain text
@Getter
@Setter
@Entity
@Table(name = "book")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY, generator = "native")
    @Column
    private int id;

    @Basic
    @Column
    private String title;

    @Basic
    @Column(name = "release_date")
    @Temporal(TemporalType.DATE)
    private Date releaseDate;

    @ManyToMany(
            fetch = FetchType.LAZY,
            mappedBy = "books"
    )
    private Set<Author> authors = new HashSet<>();

    @ManyToMany(
            fetch = FetchType.LAZY,
            mappedBy = "books"
    )
    private Set<User> users = new HashSet<>();
}
```

The @Getter and @Setter annotations used in the code examples above are part of the Project Lombok. They are used to automatically generate getters and setters. This is not mandatory and just an additional way to avoid boilerplate code. While the other annotations you can see are the standard Hibernate/JPA annotations for mapping Java classes to database tables.

#### Defining the DTOs

Now, it is time to create their corresponding DTO classes.

> Again, I recommend placing all of them in the same package. The approach I usually follow is to nest all my MapStruct DTOs under a mastruct.dtos package. So, in our example, the package will be com.mapstruct.demo.mapstruct.dtos.

Keep in mind that while defining DTOs you should think about their possible usages.

For example, as you can see the User entity has a password attribute. Because of security reasons, it's probably not the best idea to return it for example in REST GET endpoints. This is why I am going to define two different DTOs: UserPostDto and UserGetDto.

UserPostDto is going to be used while passing the data required to persist a new User to the Spring Boot application. It is defined as follows:

```plain text
@Getter
@Setter
public class UserPostDto {
    @JsonProperty("id")
    private int id;

    @Email
    @NotNull
    @JsonProperty("email")
    private String email;

    @NotNull
    @JsonProperty("password")
    private String password;

    @JsonProperty("name")
    private String name;

    @JsonProperty("surname")
    private String surname;
}
```

Note that the DTO layer is where you should define your validation logic, especially when used as input or output of your RESTful APIs.

In this example, the two required fields are email and password. This is why they are annotated with @NotNull, which is part of Spring Validation. At the same time, the @Email annotation ensures that the provided email will be in a valid format.

On the other hand, the UserGetDto will be used to expose the data of a specific user to the client application and does not require a password field.

```plain text
@Getter
@Setter
public class UserGetDto {
    @JsonProperty("id")
    private int id;

    @JsonProperty("email")
    private String email;

    @JsonProperty("name")
    private String name;

    @JsonProperty("surname")
    private String surname;
}
```

Similarly, when returning all the authors in the database you might not be interested in providing all the data on the books they wrote. In such a case, the id and the title should be enough. You can achieve such a result by defining two more DTOs: AuthorAllDto and BookSlimDto.

```plain text
@Getter
@Setter
public class AuthorAllDto {
    @JsonProperty("id")
    private int id;

    @JsonProperty("name")
    private String name;

    @JsonProperty("surname")
    private String surname;

    @JsonProperty("birthDate")
    private Date birthDate;

    @JsonProperty("books")
    private Set<BookSlimDto> books;
}
```

```plain text
@Getter
@Setter
public class BookSlimDto {
    @JsonProperty("id")
    private int id;

    @JsonProperty("title")
    private String title;
}
```

On the contrary, when returning a Book, you might be interested in providing to the client application the complete list of its Author with all the data. This is an easy task you can accomplish by creating two more DTOs: BookDto and AuthorDto.

```plain text
@Getter
@Setter
public class BookDto {
    @JsonProperty("id")
    private int id;

    @JsonProperty("title")
    private String title;

    @JsonProperty("releaseDate")
    private Date releaseDate;

    @JsonProperty("authors")
    private Set<AuthorDto> authors;
}
```

```plain text
@Getter
@Setter
public class AuthorDto {
    @JsonProperty("id")
    private int id;

    @JsonProperty("name")
    private String name;

    @JsonProperty("surname")
    private String surname;

    @JsonProperty("birthDate")
    private Date birthDate;
}
```

Now, it is time to see how to use MapStruct to automatically map our JPA entities into DTOs.

#### Defining the MapStruct Mappers

In order to work properly, MapStruct requires you to define at least one mapper. A MapStruct mapper is an interface or an abstract class annotated with @Mapper. This special annotation is used by the MapStruct code generator to automatically generate a working implementation of this Java file at build-time.

As stated in the official documentation, all readable properties from the source type (e.g. Book) will be mapped into the corresponding property in the target type (e.g. BookDto) in the generated method implementations by default.

As you can see, there is no mention of defining an implementation to the mappers. This is because MapStruct takes care of it automatically. You do not need to define any sort of mapping logic and this is where boilerplate code is avoided.

Now, it is time to show how to define a proper MapStruct mapper.

> Again, you should put all your mappers in the same package. I recommend creating a new subpackage called mappers to nest under the mapstruct one. By doing so, you will have all the classes related to MapStruct under the same mapstruct package. All told, the current package will be com.mapstruct.demo.mapstruct.mappers.

In our example, the following mapper will be enough:

```plain text
@Mapper(
    componentModel = "spring"
)
public interface MapStructMapper {
    BookSlimDto bookToBookSlimDto(Book book);

    BookDto bookToBookDto(Book book);

    AuthorDto authorToAuthorDto(Author author);

    AuthorAllDto authorToAuthorAllDto(Author author);

    List<AuthorAllDto> authorsToAuthorAllDtos(List<Author> authors);

    UserGetDto userToUserGetDto(User user);

    User userPostDtoToUser(UserPostDto userPostDto);
}
```

By setting the componentModel attribute to spring, the MapStruct processor will produce a singleton Spring Bean mapper injectable wherever you need.

Please, note that you should define an empty mapping method for each of your DTO used. For example, Book is associated with many Authors and BookDto depends on AuthorDto accordingly. So, in order to let MapStruct converting a valid Book into a BookDto, you also need to define a mapping method from AuthorDto to Author.

Another important aspect to be aware of is what happens when you deal with many-to-many relationships. When mapping the relationship attribute, the target Set (or List) will be populated by retrieving the required data using the lazy evaluation mechanism. Then, the mapping process will proceed as expected.

So, in our example, when mapping a Book instance into a BookDto instance, the authors attribute will be populated thanks to the lazy loading. Then, each of them will be converted into an AuthorDto by MapStruct using the authorToAuthorDto(Author author) method.

The mapping logic is not based on magic and if you are curious to see what the MapStruct processor actually generates at build-time, you can find the implementation mapper classes in the target/generated-sources/annotations/annotation/ folder of your project. Let's see how the generated mapper implementation looks like in our example:

```plain text
@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2021-03-11T19:21:44+0100",
    comments = "version: 1.4.2.Final, compiler: javac, environment: Java 13.0.2 (Oracle Corporation)"
)
@Component
public class MapStructMapperImpl implements MapStructMapper {

    @Override
    public BookSlimDto bookToBookSlimDto(Book book) {
        if ( book == null ) {
            return null;
        }

        BookSlimDto bookSlimDto = new BookSlimDto();

        bookSlimDto.setId( book.getId() );
        bookSlimDto.setTitle( book.getTitle() );

        return bookSlimDto;
    }

    @Override
    public BookDto bookToBookDto(Book book) {
        if ( book == null ) {
            return null;
        }

        BookDto bookDto = new BookDto();

        bookDto.setId( book.getId() );
        bookDto.setTitle( book.getTitle() );
        bookDto.setReleaseDate( book.getReleaseDate() );
        bookDto.setAuthors( authorSetToAuthorDtoSet( book.getAuthors() ) );

        return bookDto;
    }

    @Override
    public AuthorDto authorToAuthorDto(Author author) {
        if ( author == null ) {
            return null;
        }

        AuthorDto authorDto = new AuthorDto();

        authorDto.setId( author.getId() );
        authorDto.setName( author.getName() );
        authorDto.setSurname( author.getSurname() );
        authorDto.setBirthDate( author.getBirthDate() );

        return authorDto;
    }

    @Override
    public AuthorAllDto authorToAuthorAllDto(Author author) {
        if ( author == null ) {
            return null;
        }

        AuthorAllDto authorAllDto = new AuthorAllDto();

        authorAllDto.setId( author.getId() );
        authorAllDto.setName( author.getName() );
        authorAllDto.setSurname( author.getSurname() );
        authorAllDto.setBirthDate( author.getBirthDate() );
        authorAllDto.setBooks( bookSetToBookSlimDtoSet( author.getBooks() ) );

        return authorAllDto;
    }

    @Override
    public List<AuthorAllDto> authorsToAuthorAllDtos(List<Author> authors) {
        if ( authors == null ) {
            return null;
        }

        List<AuthorAllDto> list = new ArrayList<AuthorAllDto>( authors.size() );
        for ( Author author : authors ) {
            list.add( authorToAuthorAllDto( author ) );
        }

        return list;
    }

    @Override
    public UserGetDto userToUserGetDto(User user) {
        if ( user == null ) {
            return null;
        }

        UserGetDto userGetDto = new UserGetDto();

        userGetDto.setId( user.getId() );
        userGetDto.setEmail( user.getEmail() );
        userGetDto.setName( user.getName() );
        userGetDto.setSurname( user.getSurname() );

        return userGetDto;
    }

    @Override
    public User userPostDtoToUser(UserPostDto userPostDto) {
        if ( userPostDto == null ) {
            return null;
        }

        User user = new User();

        user.setId( userPostDto.getId() );
        user.setEmail( userPostDto.getEmail() );
        user.setPassword( userPostDto.getPassword() );
        user.setName( userPostDto.getName() );
        user.setSurname( userPostDto.getSurname() );

        return user;
    }

    protected Set<AuthorDto> authorSetToAuthorDtoSet(Set<Author> set) {
        if ( set == null ) {
            return null;
        }

        Set<AuthorDto> set1 = new HashSet<AuthorDto>( Math.max( (int) ( set.size() / .75f ) + 1, 16 ) );
        for ( Author author : set ) {
            set1.add( authorToAuthorDto( author ) );
        }

        return set1;
    }

    protected Set<BookSlimDto> bookSetToBookSlimDtoSet(Set<Book> set) {
        if ( set == null ) {
            return null;
        }

        Set<BookSlimDto> set1 = new HashSet<BookSlimDto>( Math.max( (int) ( set.size() / .75f ) + 1, 16 ) );
        for ( Book book : set ) {
            set1.add( bookToBookSlimDto( book ) );
        }

        return set1;
    }
}
```

MapStruct is a very versatile library and dozens of different options to achieve custom-mapping logic are available. Showing all of them is not what this article is aimed at, but if you are interested in so, I recommend reading this.

#### Putting It All Together

One last thing we need to do is define a few Rest Controllers to test our work. You can either clone the GitHub repository that supports this article or continue following this tutorial. To see your DTOs in action you just need to inject the MapStruct mapper into your controllers and use it to deal with your DTO classes.

Let’s see how our UserController will look like. The other controllers are not too different and will be omitted for brevity.

```plain text
@RestController
@RequestMapping("/users")
public class UserController {

    private MapStructMapper mapstructMapper;

    private UserRepository userRepository;

    @Autowired
    public UserController(
            MapStructMapper mapstructMapper,
            UserRepository userRepository
    ) {
        this.mapstructMapper = mapstructMapper;
        this.userRepository = userRepository;
    }

    @PostMapping()
    public ResponseEntity<Void> create(
            @Valid @RequestBody UserPostDto userPostDto
    ) {
        userRepository.save(
                mapstructMapper.userPostDtoToUser(userPostDto)
        );

        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserGetDto> getById(
            @PathVariable(value = "id") int id
    ) {
        return new ResponseEntity<>(
                mapstructMapper.userToUserGetDto(
                        userRepository.findById(id).get()
                ),
                HttpStatus.OK
        );
    }

}
```

Now, you can run your Spring Boot application and start experiencing the power of the DTO pattern and MapStruct. Finally, here are some responses from the APIs you can find in the demo project:

- http://localhost:8080/users/1

- http://localhost:8080/authors

- http://localhost/books/1

#### Aside: Securing Spring APIs with Auth0

Securing Spring Boot APIs with Auth0 is easy and brings a lot of great features to the table. With Auth0, you only have to write a few lines of code to get solid identity management solution, single sign-on, support for social identity providers (like Facebook, GitHub, Twitter, etc.), and support for enterprise identity providers (like Active Directory, LDAP, SAML, custom, etc.). In the following sections, you are going to learn how to use Auth0 to secure APIs written with Spring Boot.

##### Creating the API

First, you need to create an API on your free Auth0 account. To do that, you have to go to the APIs section of the management dashboard and click on "Create API". On the dialog that appears, you can name your API as "Contacts API" (the name isn't really important) and identify it as https://contacts.blog-samples.com (you will need this value later).

##### Registering the Auth0 Dependency

The second step is to import a dependency called auth0-spring-security-api. This can be done on a Maven project by including the following configuration to pom.xml (it's not harder to do this on Gradle, Ivy, and so on):

```plain text
    <project ...>
        <!-- everything else ... -->
        <dependencies>
            <!-- other dependencies ... -->
            <dependency>
                <groupId>com.auth0</groupId>
                <artifactId>auth0-spring-security-api</artifactId>
                <version>1.0.0-rc.3</version>
            </dependency>
        </dependencies>
    </project>
```

##### Integrating Auth0 with Spring Security

The third step consists of extending the WebSecurityConfigurerAdapter class. In this extension, you are going to use JwtWebSecurityConfigurer to integrate Auth0 and Spring Security:

```plain text
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Value(value = "${auth0.apiAudience}")
    private String apiAudience;
    @Value(value = "${auth0.issuer}")
    private String issuer;

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        JwtWebSecurityConfigurer
                .forRS256(apiAudience, issuer)
                .configure(http)
                .cors().and().csrf().disable().authorizeRequests()
                .anyRequest().permitAll();
    }
}
```

As you don't want to hard code credentials in the code, you make SecurityConfig depend on two environment properties:

---

## 18. [우리가 우리로서 일할 수 있도록, 워킹어스](http://workingus.kr/content/article/4/0/newbie)
> 생성: 2022-08-02

_(본문 없음)_

---

## 19. [KT홈허브에 ipTIME 공유기를 연결하여 멀티브릿지(리피터) 모드로 사용하기](https://itastool.tistory.com/36)
> 생성: 2022-10-20

_(본문 없음)_

---

## 20. [Finding Max and Min from List using Streams - HowToDoInJava](https://howtodoinjava.com/java8/stream-max-min-examples/)
> 생성: 2022-10-24

_(본문 없음)_

---

## 21. [데일리 스크럼 : '데일리 스크럼'을 더 잘하기 위한 생각 - 컬리 기술 블로그](https://helloworld.kurly.com/blog/daily-scrum-thinking/)
> 생성: 2023-08-09

우리는 데일리 스크럼에 대해 더 자세히 알아보고, 어떻게 하면 더 잘할 수 있을지 같이 이야기 해보았습니다.

- 시작하며 

- 데일리 스크럼에 대해 여러가지 생각을 해보고 알아본 내용을 모아보았습니다. 

- 팀원들과 함께 우리의 데일리 스크럼에 대해 이야기 해보세요. (더 나은 데일리 스크럼을 하기 위한 질문)

- 정리하며

- 같이 읽을 거리

#### 시작하며

‘데일리 스크럼’, ‘데일리 스탠드업’, ‘데일리 미팅’ 이런 이름의 미팅을 한 번씩은 들어보셨을 거에요. 아마도 지금 팀에서 하고 계신 분들도 많으실 거라 예상합니다. 또는 이름은 다르게 붙였지만 같은 성격의 미팅을 하고 계실 수도 있어요. 그만큼이나 ‘데일리 스크럼’ (이 글에서는 이러한 성격의 미팅을 ‘데일리 스크럼’ 하나로 적겠습니다.)은 소프트웨어 개발팀에서는 보편적이고 활성화된 프랙티스 (실천법, 사례, 관행의 의미) 입니다. 저는 ‘원팀으로 일하기 위한 프랙티스’로 주로 데일리 스크럼을 가장 먼저 추천합니다.

지난 달에 컬리의 프로덕트 조직 구성원들 중 데일리 스크럼에 관심이 있는 분들이 모여서 데일리 스크럼에 대해서 더 자세히 알아보고, 몇 가지 질문에 답해보면서 의견을 나누었어요. 이 중에 어떻게 하면 데일리 스크럼이 최악이 되는지에 대한 생각도 공유 했는데요. 다음과 같은 몇 가지로 정리를 할 수 있었습니다.

##### 질문. “어떻게 하면 데일리 스크럼을 최악의 이벤트로 만들 수 있을까요?”

데일리 스크럼을 최악으로 만드는 아이디어를 적어본 것이라, 이 중 어떤 것들은 실제로 벌어지지는 않은 상상을 해 본 것일 거에요. 중요한 점은 데일리 스크럼이 최악의 이벤트가 되지 않도록 하려면, “제대로 아는 것이 필요하고, 효과적으로 활용하는 환경을 조성해야 하는구나.” 라는 것을 알게 되었다는 것입니다.

#### 데일리 스크럼에 대해 여러가지 생각을 해보고 알아본 내용을 모아보았습니다.

우리가 하고 있는 데일리 스크럼이 어디에서 온 것인지 생각해 보신적이 있나요? 내가 일을 시작할 때부터 팀에서 하고 있어서, 또는 팀장님이 매일 업무를 논의하는 회의를 해보자고 해서 하고 있었던 데일리 스크럼. 누군가에게는 지루하고 아침부터 진이 빠지는 관행이 되기도 하는 이 미팅을 잘하려면 어떻게 해야할까요? 시작은 어디에서 온 것이며, 어떤 목적으로 어떻게 하는 것으로 생겨난 것인지를 알아야 할 것입니다.

데일리 스크럼은 어떻게 생겨나서 어디서 온 것 일까요?

데일리 스크럼은 스크럼 프레임워크에 속한 이벤트 입니다. 데일리 스크럼과 같은 목적과 방식의 프랙티스인데 명칭은 다른 미팅이 있습니다. 다른 명칭을 가진 데일리 미팅들은 각기 다른 기원을 가지고 있습니다.

##### 먼저 스크럼 프레임워크를 간략히 알아봅시다.

스크럼 Scrum (스크럼 프레임워크를 줄여서 말해서)은 애자일 Agile 을 실천하는 가장 보편화 된 방안으로 널리 활용되고 있습니다. 애자일 프로덕트 개발은 지속적으로 점진적이고 반복적인 개발을 하면서 불확실한 부분을 결과물로 만들어 가는 여정인데요. 스크럼은 실행한 경험을 기반으로 프로덕트와 팀을 개선하는 사이클을 어떻게 반복적으로 수행할 것인지 보다 구체적으로 제시한 일 하는 방식에 대한 프레임워크 입니다. 애자일을 어떻게 실행할 수 있을지 고민하는 경우에 스크럼을 기반으로 일을 하면 자연스럽게 지속적인 개선 사이클을 실천할 수 있습니다.

팀 단위에서는 스크럼을 많이 활용합니다. 팀 단위에서 실행하는 애자일 방법론/프레임워크 중에 스크럼을 활용하는 비율이 66% 라는 설문 결과 (출처: 15th State of Agile Report)

스크럼 프레임워크는 총 다섯 가지 이벤트를 팀이 수행할 것을 가이드하고 있는데요. 이것을 스크럼 이벤트라고 하고, 스프린트, 스프린트 계획, 데일리 스크럼, 스프린트 리뷰, 스프린트 회고가 있습니다. 이 중 스프린트 기간 중에 일 단위로 실행하는 이벤트로 제시된 것이 바로 ‘데일리 스크럼’ Daily Scrum 입니다.

> 스크럼 (프레임워크)은 데일리 스크럼과 다른 것 이군요? 그렇다면, 데일리 스크럼과 같은 미팅을 ‘스크럼’ 이라고만 부르면, 혼동이 될 수도 있겠네요.

스크럼 프레임워크 모델 위에 데일리 스크럼이 위치한 곳을 ⭕️로 표시한 그림 입니다.

##### 데일리 스크럼 이라는 단어는 무슨 뜻이에요 ?

스크럼 프레임워크의 스크럼은 스포츠 럭비에서 가져온 용어 입니다. 럭비는 2개의 팀이 축구장과 비슷한 잔디구장 위에 정해진 규칙에 따라 득점을 하고 득점이 많은 팀이 승리하는 경기입니다. 경기 중 진행이 일시 정지된 후 경기를 재개할 때 팀이 갖추는 기본 대형을 스크럼이라고 합니다.

스크럼 프레임워크는 프로덕트를 만드는 스크럼 팀이 둥글게 모여서 하나의 목표를 달성하기 위해 뭉친 럭비 팀의 형태처럼 일을 한다는 개념에서 스크럼 이라는 단어를 사용했어요. 스크럼 팀이 매일 다시 뭉치는 이벤트는 일 단위의 수식을 붙여서 데일리 스크럼 Daily Scrum 이라고 합니다.

럭비(15인제)의 스크럼 대형 (사진: Pixabay License)

##### 데일리 스크럼을 하는 모습

스크럼 가이드 (스크럼 프레임워크를 어떻게 하는지 규칙을 소개하는 공식 가이드 북. 스크럼 가이드 2020)는 데일리 스크럼을 15분의 제한된 시간 내에 할 것으로 가이드 하였습니다. 짧은 시간동안 필요한 내용만을 이야기 할 것을 유도하기 위함 입니다.

실제 사례에서는 짧게 진행하기 위해서 별도의 회의실을 이용하거나 앉아서 편하게 하는 것을 지양하게 되었고, 서서 진행하는 방식 때문에 ‘데일리 스탠드 업’ Daily Stand-up 이라고도 합니다.

업무를 하는 공간 바로 옆에서 팀이 모여 서서 대화합니다.  (출처: It's Not Just Standing Up: Patterns for Daily Standup Meetings)  (사진: Karthik Chandrasekarial)

Plank meeting. pic.twitter.com/A6ASL4DrrT짧게 하기 위한 노력: 플랭크 미팅  (출처: Richard Banfield on Twitter)

##### 데일리 스크럼과 비슷한 목적이지만 다른 이름을 가진 이벤트

데일리 스크럼과 비슷한 성격으로 가장 많이 사용하는 다른 2가지 명칭(daily standup, daily huddle)의 이벤트를 대상으로 데일리 스크럼과 함께 키워드 트렌드를 살펴보았습니다. 이 중에 데일리 스탠드 업은 영어로 표기할 때 여러 형태가 있어서, daily standup, daily stand-up, daily standups 3가지는 하나의 키워드로 봐야합니다. 결과로는 Google Books Ngram Viewer 와 Google Trends 모두 daily scrum 이라는 단어 표현이 가장 많이 사용되고 있음을 알 수 있습니다.

Daily Huddle 은 1930~1940 년대부터 미국 지역에서 나타난 키워드이고, 규칙이나 제약이 가장 적은 형태로 정의된 개념입니다. 업종이나 스크럼 프레임워크와 관련없이, 팀이 매일 모여서 필요한 대화를 하자는 프랙티스로 볼 수 있겠습니다. (참고 자료: Daily Huddle: Everything You Need For a Great Huddle Meeting)

Daily Meeting 은 키워드 사용 수는 많은데요. 미팅 형태나 목적이 데일리 스크럼과 같다고 하기에 모호한 부분이 있어서, 키워드 분석 대상 항목에서는 제외하였습니다.

Google Books Ngram Viewer 는 출판된 책 내에 사용된 말뭉치의 사용 비율을 보여줍니다.  키워드: daily scrum, daily standup, daily stand-up, daily standups, daily huddle  조회 기간: 2000~2019년도

Google Trends 는 구글 검색의 검색 쿼리를 키워드 간 상대적으로 비교한 수치로 보여줍니다. 키워드: daily scrum, daily standup, daily stand-up, daily standups, daily huddle 조회 기간: 2004.5.1~2022.12.14

##### 데일리 스크럼은 왜 하나요?

애자일을 지향하면서 일을 하게 되면 진행하는 일을 각기 다른 여러 주기의 사이클을 가지고 점검합니다. 그 중에 데일리 스크럼은 하루 단위의 점검 사이클 역할을 합니다. 팀이 가진 목표를 달성하기 위해서, 팀원들의 정신적인 단결과 목표를 재확인 하는 것 입니다. 팀원들이 가지고 있는 방해 요소와 문제 사항도 이야기 할 수 있게 하고, 찾아낸 장애물은 해결할 수 있게 행동으로 이어갑니다. 데일리 스크럼에서 할 일의 상황과 진척에 필요한 도움을 확인함으로써 팀원 각자가 오늘 어떤 일을 어떻게 할 것인지 명확한 계획을 갖습니다. 이것을 반복하면 스크럼 팀은 스스로를 관리 Managing 하는 자율경영 조직으로 변화할 수 있습니다.

애자일의 실천 방법 중 한 가지인 익스트림 프로그래밍의 여러 주기의 피드백 루프 (출처: File:Extreme Programming.svg)

##### 데일리 스크럼은 어떻게 진행하나요?

일반적으로 다음 두 가지 방식으로 진행합니다.

1) 한 사람씩 자신이 말할 내용을 이야기 합니다.

2) 보드(백로그)에 있는 업무 이슈 하나씩 보면서 관련된 사항을 이야기 합니다.

스크럼 가이드 2017 에서는 데일리 스크럼에 참여한 사람들이 각자 다음과 같은 3가지 질문에 답을 하는 형식으로 이야기 할 것을 권장하였습니다. 데일리 스크럼의 목적에 맞게 구상한다면, 팀이 팀의 특성에 맞는 새로운 질문 세트를 정할 수도 있을 것입니다.

대화가 시간 내에 원활하게 될 수 있도록 누군가가 말할 사람을 호명해 주거나 길어지는 대화는 정리해 주는 역할을 할 수 있습니다.

##### 데일리 스크럼에 대한 몇 가지 질문과 저의 답변

##### 데일리 스크럼을 지속적으로 잘 하기 위한 요점

##### 나의 작은 팁 (이렇게 하면 좋은 데일리 스크럼 활동을 유지하는 데에 도움이 되었어요.)

컬리의 딜리버리프로덕트 조직의 한 팀이 데일리 스크럼을 마치고 팀 구호를 외치고 있습니다.  데일리 스크럼은 스포츠 팀의 작전타임과 비슷한 기능을 합니다.  (사진: 컬리 에서, © 2022. Kurly. All rights reserved.)

#### 팀원들과 함께 우리의 데일리 스크럼에 대해 이야기 해보세요. (더 나은 데일리 스크럼을 하기 위한 질문)

#### 정리하며

아주 간단한 미팅이라고 생각했던 데일리 스크럼에 대해서, 쓰다보니 생각할 측면이 많다는 것을 발견하게 되었습니다. 데일리 스크럼이 형식만 남아서 힘 빠지게 하거나 지루한 보고 미팅이 되지 않게 하려면 지속적인 관심과 개선이 필요합니다. 눈에 보이지 않는 팀의 에너지를 느껴보고 더 나은 데일리 스크럼이 될 수 있도록 함께 실천하면서 주기적으로 팀원들과 의견을 나누어 보세요.

---

## 22. [소프트웨어 엔지니어링 팀은 기술 부채를 어떻게 추적합니까? | AppMaster](https://appmaster.io/ko/blog/sopeuteuweeo-enjinieoring-timeun-gisul-bucaereul-eoddeohge-cujeoghanayo)
> 생성: 2023-09-17

#### 기술 부채 이해

기술 부채는 소프트웨어 개발 의 개념으로, 프로젝트 설계, 코딩 및 구현 단계에서 균형을 이루는 최종 비용을 나타냅니다. 기술 부채는 기한을 맞추기 위해 선택한 지름길, 최적이 아닌 설계 선택, 부적절한 문서, 제한된 리소스로 인해 발생할 수 있습니다. 이러한 절충안은 프로젝트가 성장함에 따라 유지 관리 가능성, 효율성 및 확장성을 저해할 수 있는 장기적인 결과를 초래하는 경우가 많습니다.

소프트웨어 개발의 복잡성으로 인해 일부 기술적 부채는 불가피하지만 이를 점검하는 것이 필수적입니다. 해결하지 않고 방치하면 기술 부채가 눈덩이처럼 불어나 엄청난 문제로 커질 수 있으며, 이로 인해 향후 변경에 필요한 노력이 늘어나고 개발 시간이 추가되며 해결을 위해 광범위한 리팩토링이 필요할 수도 있습니다. 기술 부채, 측정 및 의미를 잘 이해하면 소프트웨어 엔지니어링 팀이 이를 효과적으로 처리하는 데 도움이 될 수 있습니다.

#### 추적 방법 및 도구

소프트웨어 엔지니어링 팀이 기술 부채를 효과적으로 식별, 모니터링 및 관리하는 데 도움이 되는 여러 가지 추적 방법과 도구가 있습니다. 이러한 추적 솔루션은 프로젝트 전반에 걸쳐 기술 부채의 양과 질을 지속적으로 파악하여 기술 부채가 심각한 문제가 되는 것을 방지하는 데 매우 중요합니다. 널리 사용되는 기술 부채 추적 방법 및 도구는 다음과 같습니다.

##### 코드 분석 도구

정적 분석기라고도 하는 코드 분석 도구는 코드베이스에서 코딩 표준, 구문 오류, 잠재적인 취약점과 같은 문제를 검색합니다. 이러한 도구는 즉각적인 피드백을 제공하고 개발 초기에 기술 부채 징후를 감지합니다. 정적 분석 도구의 예로는 SonarQube, ESLint 및 ReSharper가 있습니다.

##### 코드 검토 관행

코드 검토는 기술 부채를 통제할 수 있는 검증된 방법입니다. 체계적인 코드 검토 프로세스에서 팀 구성원은 서로의 코드 변경 사항을 검토하고 제안과 피드백을 제공합니다. 이러한 협업 접근 방식은 기술 부채가 코드베이스에 뿌리내리기 전에 개발이 진행되는 동안 이를 식별하는 데 도움이 될 수 있습니다. 코드 검토를 용이하게 하는 인기 있는 코드 관리 플랫폼에는 GitHub, GitLab 및 Bitbucket이 있습니다.

##### 지속적인 통합 및 배포

CI(지속적 통합) 및 CD(지속적 배포) 플랫폼은 소프트웨어 코드 변경 사항의 자동화된 빌드, 테스트 및 배포를 간소화합니다. 이를 통해 엔지니어링 팀은 개발 초기에 문제를 감지하고 수정할 수 있습니다. 이를 통해 CI/CD 파이프라인은 코드 품질 검사를 시행하여 기술적 부채 축적을 정확히 찾아내고 방지할 수 있습니다. CI/CD 플랫폼의 예로는 Jenkins, CircleCI 및 GitHub Actions가 있습니다.

##### 이슈 추적 시스템

많은 엔지니어링 팀에서는 문제 추적 시스템을 사용하여 작업, 버그 및 기술 부채 항목을 추적합니다. 이러한 추적기를 통해 개발자는 기술 부채 항목을 문서화하고 정기적인 유지 관리 주기, 프로젝트 백로그 또는 스프린트 계획 세션에서 해결 방법을 계획할 수 있습니다. 잘 알려진 문제 추적 시스템으로는 Jira, Trello 및 Asana 가 있습니다.

##### 기술 부채 대시보드

기술 부채 대시보드는 다양한 추적 도구의 데이터를 집계하여 프로젝트의 기술 부채 수준에 대한 가시성을 제공합니다. 잘 구성된 대시보드는 특정 코드 영역이나 팀의 기술 부채 규모와 심각도에 대한 통찰력을 제공할 수 있습니다. 이러한 대시보드 도구 중 하나는 소스 코드 저장소, 문제 추적 시스템 및 코드 분석 도구의 데이터를 고려하는 CodeScene입니다.

#### 기술 부채 식별 및 우선순위 지정

추적 방법과 도구는 기술 부채를 모니터링하는 데 도움이 될 수 있지만 이를 효과적으로 해결하려면 명확한 식별 및 우선순위 지정 프로세스를 확립하는 것이 중요합니다. 다음 단계는 팀이 가장 중요한 기술 부채 항목을 먼저 해결하는 데 도움이 될 수 있습니다.

1. 기술 부채 범주 정의: 기술 부채는 코드 부채, 설계 부채, 인프라 부채, 문서 부채, 테스트 자동화 부채 등 다양한 범주로 분류할 수 있습니다. 기술 부채를 명확하게 이해하고 분류하면 심각도를 측정하기 위한 표준과 벤치마크를 정의하는 데 도움이 됩니다.

1. 심각도 수준 설정: 개발자가 기술 부채 항목의 영향을 평가하고 해결 우선 순위를 지정하는 데 도움이 될 수 있는 기술 부채의 심각도 수준 집합을 정의합니다. 일반적으로 심각도는 잠재적 위험, 부채 수정에 필요한 노력, 유지 관리 및 확장성에 미치는 영향 등의 요소를 기준으로 낮음, 중간, 높음, 중요 수준으로 분류됩니다.

1. 측정항목을 사용하여 기술 부채 평가: 다양한 측정항목을 활용하면 팀에서 기술 부채를 정량화하고 시간 경과에 따른 추세를 모니터링할 수 있습니다. 이러한 측정항목에는 코드 변동, 코드 적용 범위, 코드 복잡성 및 버그 수가 포함될 수 있습니다. 코드베이스에서 기술 부채의 존재와 범위를 나타내는 데 도움이 될 수 있습니다.

1. 개발 프로세스에 기술 부채 관리 포함: 기술 부채의 우선순위를 효과적으로 지정하려면 이를 계획 세션, 스프린트 검토, 회고와 같은 소프트웨어 개발 프로세스 에 통합하세요. 이러한 행사 중에 기술 부채 항목을 정기적으로 다시 방문하면 초점을 유지하고 시기적절한 해결을 장려하는 데 도움이 됩니다.

기술 부채 관리는 소프트웨어 엔지니어링 팀의 지속적인 경계가 필요한 지속적인 프로세스입니다. 기술 부채의 주요 측면을 이해하고, 올바른 추적 방법과 도구를 사용하고, 적절한 식별 및 우선 순위 지정 접근 방식을 적용함으로써 팀은 소프트웨어 개발 성공에 미치는 영향을 줄일 수 있습니다.

Try AppMaster no-code today!

Platform can build any web, mobile or backend application 10x faster and 3x cheaper

Start Free

#### 기술 부채 완화 및 상환

기술 부채를 완화하고 상환하기 위한 포괄적인 전략은 소프트웨어 엔지니어링 프로젝트의 장기적인 건전성을 보장하는 데 매우 중요합니다. 이 섹션에서는 기술 부채를 효과적으로 해결하기 위해 팀에서 구현할 수 있는 몇 가지 조치에 대해 설명합니다.

##### 기술 부채 관리에 시간 할당

기술 부채 관리에 자원을 투자하는 것이 중요합니다. 기술 부채 감소를 위해 개발 주기의 특정 부분을 정기적으로 할당합니다. 일반적으로 사용 가능한 시간의 약 10~20%를 기술 부채를 해결하는 데 사용해야 합니다. 그러나 실제 필요한 시간은 프로젝트의 기간과 복잡성에 따라 달라질 수 있습니다.

##### 리팩토링 계획

리팩토링을 개발 프로세스의 지속적인 부분으로 만드세요. 리팩토링은 외부 동작을 변경하지 않고 기존 코드를 수정하여 디자인, 가독성 및 구조를 개선하는 것을 의미합니다. 코드 검토 세션을 통합하여 개선 영역과 잠재적 기술 부채를 식별합니다. 이러한 활동에 시간을 할당하고 상당한 리팩터링이 필요한 레거시 코드를 모니터링하십시오.

##### 품질 우선 접근 방식 채택

기술 부채 축적을 방지하려면 처음부터 고품질 코드 생성에 집중하세요. 코딩 표준, 테스트 중심 개발(TDD), 지속적인 통합, 코드 검토와 같은 모범 사례를 장려합니다. 이러한 관행은 고품질 코드를 보장하고 기술 부채 누적 위험을 줄입니다.

##### 점진적인 개선

코드베이스에서 가장 심각한 기술 부채를 생성하는 영역을 식별하고 점진적으로 상환을 시작하세요. 대규모 코드 개선 프로젝트는 시간이 많이 걸리고 파괴적일 수 있습니다. 대신 프로세스를 각 개발 반복에서 처리할 수 있는 더 작고 관리 가능한 작업으로 나누십시오.

##### 기술 부채 모니터링 및 측정

핵심성과지표(KPI)를 설정하여 기술 부채 누적을 추적하고 이를 점검하세요. 측정항목에는 코드 복잡성, 코드 적용 범위, 버그 수, 결함 밀도 및 코드 변동이 포함될 수 있습니다. 이러한 지표를 정기적으로 모니터링하면 프로젝트 상태에 대한 통찰력을 얻을 수 있고 주의가 필요한 영역을 식별하는 데 도움이 될 수 있습니다.

#### 기술 부채 인식 문화 조성

기술 부채를 효과적으로 관리하려면 소프트웨어 엔지니어링 팀 내에서 부채 인식 문화를 조성하는 것이 중요합니다. 기술 부채에 대한 책임감과 사전 대응 문화를 조성하기 위해 취할 수 있는 몇 가지 단계는 다음과 같습니다.

##### 인식 제고

기술 부채의 개념과 결과에 대해 팀원을 교육합니다. 제대로 관리되지 않은 기술 부채로 인해 발생하는 부정적인 결과에 대한 실제 사례를 공유하여 기술 부채 관리 및 감소의 중요성을 이해하도록 도와주세요.

##### 열린 의사소통 장려

기술 부채에 관해 팀원들 간의 공개 대화를 장려합니다. 이 커뮤니케이션이 솔루션 지향적이고 비난 없는 환경에 기반을 두고 있는지 확인하세요. 동료 피드백을 장려하고 확인된 기술 부채를 해결하기 위한 잠재적 전략을 논의합니다.

##### 기술 부채 관리에 대한 인센티브 제공

기술 부채를 줄이기 위한 적극적인 노력에 대해 팀원에게 보상하십시오. 기술 부채 감소와 관련된 KPI를 설정하고 이러한 목표를 개인 및 팀 성과 평가와 연결합니다.

##### 모든 이해관계자를 참여시키세요

기술 부채를 해결하는 데 제품 관리자, 비즈니스 분석가 및 기타 이해관계자를 포함시킵니다. 누적된 부채의 결과에 대해 교육하고 적시에 정기적인 부채 관리의 이점을 전달합니다.

##### 교육 및 도구에 투자

모범 사례, 코딩 표준 및 리팩토링 기술에 대한 적절한 교육을 제공합니다. 기술 부채를 식별, 추적 및 대처할 수 있는 신뢰할 수 있는 도구와 기술을 팀에 제공하십시오. 기술 부채 인식 문화를 조성함으로써 소프트웨어 엔지니어링 팀은 확장 가능하고 유지 관리가 가능하며 효율적인 고품질 코드를 유지하면서 기술 부채 축적을 최소화할 수 있습니다.

#### AppMaster: 설계상 기술적 부채 없음

AppMaster는 기술 부채 문제를 해결하는 독특한 방법을 제공합니다. 코드가 없는 플랫폼은 웹, 모바일 및 백엔드 애플리케이션 개발을 촉진하고 기술 부채를 완전히 제거하는 데 중점을 둡니다. 또한 요구 사항이 변경될 때마다 처음부터 애플리케이션을 신속하게 생성하여 애플리케이션을 더 빠르고 비용 효율적으로 업데이트할 수 있습니다. 기존 개발 방법과 달리 이 접근 방식은 기술 부채가 누적되지 않도록 보장하여 품질과 성능을 저하시키지 않으면서 확장 가능한 솔루션을 제공합니다.

AppMaster 플랫폼을 구현하면 기술 부채 추적 및 관리의 복잡성을 크게 줄이고 애플리케이션 개발 프로세스를 간소화할 수 있습니다. 이를 통해 소프트웨어 엔지니어링 팀은 기술 부채로 인한 장기적인 결과에 대해 걱정하지 않고 확장 가능한 고품질 애플리케이션을 제공하는 데 집중할 수 있습니다. 60,000명 이상의 사용자를 보유한 AppMaster 플랫폼은 백엔드, 웹 및 모바일 애플리케이션 분야에서 더 나은 소프트웨어 개발 결과를 보장합니다. 노코드 플랫폼 은 No-code 개발 플랫폼, RAD(신속한 애플리케이션 개발) 등을 포함한 여러 범주에서 G2에 의해 고성능 및 모멘텀 리더로 인정받았습니다.

기술 부채를 관리하고 줄이는 것이 소프트웨어 엔지니어링 팀의 최우선 과제입니다. 올바른 전략, 도구 및 문화를 사용하면 축적된 기술 부채의 위험과 결과를 완화할 수 있습니다. 동시에 AppMaster 플랫폼과 같은 솔루션을 채택하면 스트레스 없는 개발 및 유지 관리 프로세스가 촉진되어 보다 효율적이고 수익성 있는 소프트웨어 프로젝트가 가능해집니다.

#### AppMaster와 같은 코드 없는 플랫폼은 소프트웨어 엔지니어링 팀이 기술 부채를 보다 효율적으로 추적하고 해결하는 데 도움을 줄 수 있습니까?

예, AppMaster 와 같은 no-code 플랫폼은 신속한 개발 및 코드 최적화를 위한 도구와 기능을 제공하여 기술 부채를 해결하는 프로세스를 단순화할 수 있습니다. 이를 통해 팀은 새로운 기능과 개선 사항을 제공하는 데 초점을 맞추면서 기술 부채를 해결하는 데 도움이 될 수 있습니다.

#### 소프트웨어 엔지니어링 팀에 기술 부채 추적이 중요한 이유는 무엇입니까?

기술 부채 추적은 소프트웨어 품질과 프로젝트 효율성을 유지하는 데 중요합니다. 이는 팀이 개선이 필요한 영역을 식별하고 리소스를 효과적으로 할당하며 장기적인 유지 관리 가능성을 보장하는 데 도움이 됩니다.

#### 기술 부채를 효과적으로 추적하고 관리하기 위한 모범 사례는 무엇입니까?

모범 사례에는 명확한 문서 유지, 정기적인 코드 검토 수행, 리팩토링 시간 할당, 의사 결정에 이해관계자 참여, 지속적인 개선 문화 조성 등이 포함됩니다.

#### 소프트웨어 엔지니어링 팀은 기술 부채를 추적하기 위해 어떤 도구나 방법론을 사용할 수 있나요?

팀에서는 종종 버전 제어 시스템(예: Git), 문제 추적 도구(예: Jira), 코드 분석 도구(예: SonarQube) 및 Agile 또는 DevOps와 같은 개발 방법론을 사용하여 기술 부채를 추적하고 관리합니다.

#### 소프트웨어 개발에서 기술적 부채란 무엇입니까?

기술 부채는 시간이 지남에 따라 코드 품질이 저하되고 유지 관리 노력이 증가할 수 있는 축적된 소프트웨어 설계 또는 코드 지름길을 의미합니다. 장기적인 솔루션보다 빠른 수정을 우선시하는 경우가 많습니다.

#### 소프트웨어 엔지니어링 팀은 기술 부채를 어떻게 식별합니까?

기술 부채는 코드 검토, 자동화된 코드 분석 도구, 정기적인 회고, 팀 구성원 간의 토론을 통해 식별할 수 있습니다. 복잡하거나 오래된 코드, 해결 방법, 알려진 문제가 특징인 경우가 많습니다.

---

## 23. [기술 부채: 예시 및 유형 | AppMaster](https://appmaster.io/ko/blog/gisul-bucae-yesi-mic-yuhyeong)
> 생성: 2023-09-24

#### 기술 부채란 무엇입니까?

기술 부채는 소프트웨어 개발 프로젝트에서 코드의 유지 관리, 향상 또는 이해를 더욱 어렵게 만들 수 있는 절충안, 지름길, 오래된 기술 또는 관행의 축적을 설명하는 비유입니다. 이는 개발자가 모범 사례보다 편리한 솔루션을 선택하여 장기적인 소프트웨어 문제가 발생하고 나중에 문제를 해결하기 위한 추가 노력이 발생할 때 발생합니다. 기술 부채는 촉박한 기한, 적절한 리소스 부족, 모범 사례에 대한 지식 부족 등의 요인으로 인해 발생할 수 있습니다.

시간이 지남에 따라 기술 부채가 누적되면 개발 비용이 증가하고 릴리스 주기가 느려지며 코드 품질이 저하되어 팀의 생산성과 혁신 잠재력에 영향을 미칠 수 있습니다. 소프트웨어 프로젝트의 성공과 효율성을 보장하려면 기술 부채를 해결하는 것이 중요합니다. 해당 유형을 이해하고, 코드 문제를 식별하고, 모범 사례를 사용하여 이를 최소화함으로써 소프트웨어 제품의 유지 관리성과 확장성을 향상시킬 수 있습니다.

#### 기술 부채의 유형

기술 부채는 근본 원인, 결과, 계획된 정도와 계획되지 않은 정도에 따라 여러 유형으로 분류될 수 있습니다. 기술 부채의 일반적인 유형은 다음과 같습니다.

- 의도적인 기술 부채 - 의도적인 기술 부채는 개발자가 빡빡한 기한이나 예산 제약과 같은 외부 압력으로 인해 고의로 최상의 옵션 대신 빠르고 차선책인 솔루션을 선택할 때 발생합니다. 여기에는 이러한 선택이 나중에 재검토되고 개선되어야 한다는 점을 이해하면서 단기적으로 계획된 절충안이 포함됩니다.

- 의도하지 않은 기술 부채 - 의도하지 않은 기술 부채는 시간이 지남에 따라 누적되어 소프트웨어 프로젝트의 유지 관리 가능성에 영향을 미치는 잘못된 관행, 부적절한 지식 또는 우발적인 코드 오류로 인해 발생합니다. 이 부채는 개발, 테스트 또는 배포 중에 문제가 발생할 때까지 눈에 띄지 않는 경우가 많습니다.

- '비트 로트(Bit Rot)' 기술 부채 - 기술 노후화라고도 알려진 이러한 유형의 부채는 소프트웨어 프로젝트가 더 이상 지원되지 않거나 널리 사용되지 않는 오래된 기술, 라이브러리 또는 프레임워크에 의존할 때 발생합니다. 이러한 오래된 구성 요소를 사용하면 호환성 문제, 확장성 제한, 유지 관리 노력 증가가 발생할 수 있습니다.

위의 기술 부채 유형은 대부분의 시나리오에 적용되지만 눈에 띄지는 않지만 그만큼 해로울 수 있는 또 다른 유형의 부채가 있습니다. 바로 코드 엔트로피입니다.

#### 파악하기 어려운 기술 부채: 코드 엔트로피

코드 엔트로피는 복잡성과 무질서의 증가로 인해 코드베이스의 품질과 유지 관리 가능성이 점차 감소하는 것을 의미하는 기술적 부채의 한 형태입니다. 새로운 기능이 추가되고, 기존 코드가 리팩터링되고, 버그가 수정되면서 코드베이스가 더욱 복잡해지는 경향이 있어 개발자가 작업하기가 어려워집니다. 코드 엔트로피는 종종 다음과 같은 결과로 나타납니다.

- 불충분한 리팩토링: 개발 중에 코드가 적절하게 리팩터링 및 최적화되지 않으면 복잡성이 증가하여 유지 관리가 어려운 코드베이스가 발생할 수 있습니다.

- 일관되지 않은 코딩 관행: 팀 전체에 일관된 코딩 표준 및 관행이 없으면 코드베이스가 체계화되지 않아 읽고 이해하고 유지 관리하기가 어려워질 수 있습니다.

- 높은 개발자 이직률: 팀 구성이 자주 변경되면 다양한 코딩 스타일과 습관이 코드베이스에 도입되어 불일치가 발생하고 무질서가 증가할 수 있습니다.

코드 엔트로피는 파악하기 어렵고 널리 퍼져 있는 기술 부채 형태이므로 식별하고 해결하기 어려울 수 있습니다. 좋은 개발 방식을 채택하고 코드 품질에 주의를 기울이면 코드 엔트로피를 방지하고 소프트웨어 프로젝트를 유지 관리 및 확장 가능하게 유지할 수 있습니다.

#### 기술 부채의 예

기술 부채는 다양한 형태로 발생하며 다양한 원인으로 인해 발생할 수 있습니다. 다음은 소프트웨어 개발 프로젝트에서 발생하는 기술적 부채의 몇 가지 일반적인 예입니다.

- 불충분한 문서화: 문서화가 부족하거나 문서가 없는 프로젝트는 개발자가 코드, 기능 또는 아키텍처의 목적을 오해하게 만들 수 있습니다. 이로 인해 잘못된 가정이 이루어지거나 새로운 개발자가 시스템을 이해하는 데 어려움을 겪을 때 기술 부채가 축적될 수 있는 지식 격차가 발생합니다.

- 중복 코드: 시스템의 다른 부분에서 코드 중복 또는 코드 복사-붙여넣기는 팀이 코드 재사용 기회를 제대로 고려하지 않았음을 나타냅니다. 중복 코드의 각 인스턴스를 별도로 업데이트해야 하므로 유지 관리 부담이 발생합니다.

- 더 이상 사용되지 않는 라이브러리 또는 API: 프로젝트가 오래된 라이브러리 또는 API 에 의존하는 경우 해당 종속성이 지원되지 않으므로 보안, 유지 관리 및 확장이 점점 더 어려워집니다. 이러한 형태의 기술 부채를 '비트 부패'라고 합니다.

- 자동화된 테스트 부족: 자동화된 테스트가 부족하면 수동 테스트 주기가 길어지고 개발자가 자동화된 안전망 없이 기존 코드를 변경함에 따라 회귀가 발생할 수 있습니다. 이로 인해 개발 속도가 느려지고 기술 부채가 누적될 가능성이 높아집니다.

- 비효율적인 오류 처리: 오류가 제대로 처리되지 않고 적절한 수정 조치를 취하지 않고 예외가 무시되거나 기록되면 취약한 시스템이 생성되고 결국 버그나 충돌로 표면화되는 기술적 부채가 남을 수 있습니다.

- 불명확하거나 지나치게 복잡한 코딩 패턴: 코드는 의도한 기능을 달성하면서도 최대한 단순해야 합니다. 불필요하게 복잡하거나 이해하기 어려운 코딩 패턴으로 인해 다른 개발자가 시스템을 확장하거나 개선하는 것이 어려울 수 있습니다.

- 긴밀하게 결합된 구성 요소: 시스템 내의 구성 요소가 높은 수준의 종속성을 가지면 계단식 문제를 일으키지 않고 리팩터링하거나 수정하기 어려운 취약한 아키텍처가 생성됩니다. 한 구성 요소의 변경 사항이 다른 종속 구성 요소에 영향을 미칠 수 있으므로 기술 부채 위험이 증가합니다.

#### 기술 부채를 식별하는 방법

기술 부채를 식별하는 것은 소프트웨어 개발 팀이 혁신과 유지 관리 간의 올바른 균형을 유지하는 데 중요합니다. 다음은 프로젝트에서 기술 부채의 존재를 식별하는 데 도움이 되는 몇 가지 기술입니다.

1. 프로젝트 문서 조사: 적절한 문서는 코드의 원래 의도를 이해하고 기술적 부채가 도입되었을 수 있는 편차, 격차 또는 우려 영역을 식별하는 데 도움이 될 수 있습니다.

1. 코드 냄새 찾기: 코드 냄새는 긴 메서드, 대규모 클래스 또는 중복 코드와 같은 소프트웨어 설계의 잠재적인 문제를 나타냅니다. 이러한 코드 냄새를 식별하고 해결하면 잠재적인 기술 부채 영역을 찾아내는 데 도움이 될 수 있습니다.

1. 코드 모듈성 평가: 모듈 또는 구성 요소의 계층 구조와 종속성을 평가하면 밀접하게 결합된 시스템을 식별하는 데 도움이 될 수 있습니다. 이는 숨어 있는 기술 부채의 신호인 경우가 많습니다.

1. 사용된 기술의 시대를 고려하십시오. 오래된 라이브러리, API 또는 프로그래밍 언어는 지원이 중단되고 호환성을 유지하기 위해 더 많은 노력이 필요하므로 기술적 부채가 될 수 있습니다.

1. 성능 및 오류율 모니터링: 애플리케이션의 성능과 오류율을 주시하면 기술 부채로 인해 문제가 발생할 수 있는 영역을 식별하는 데 도움이 될 수 있습니다. 빈번한 충돌, 느린 페이지 로드 시간 또는 증가하는 메모리 사용량은 해결해야 할 기술적 부채의 지표일 수 있습니다.

Try AppMaster no-code today!

Platform can build any web, mobile or backend application 10x faster and 3x cheaper

Start Free

#### 기술 부채 최소화: 모범 사례

기술 부채의 축적을 최소화하려면 소프트웨어 개발에서 다음 모범 사례를 따를 수 있습니다.

- 철저한 계획: 사전에 시간을 들여 아키텍처와 설계를 철저하게 계획하는 것은 솔루션이 견고한 기반을 갖추고 잘못된 결정이나 지름길로 인해 과도한 기술 부채가 쌓이는 것을 방지하는 데 도움이 됩니다.

- 코드 검토: 정기적인 코드 검토는 잠재적인 문제를 조기에 파악하고 코드베이스 전체의 일관성을 보장하는 데 도움이 됩니다. 또한 팀에 학습 기회를 제공하여 지속적인 개선 문화를 조성합니다.

- 지속적인 리팩토링: 코드를 정기적으로 리팩토링하면 코드베이스를 깔끔하고 모듈식이며 유지 관리 가능하게 유지하는 데 도움이 됩니다. 시간이 지남에 따라 기술적 부채가 누적되지 않도록 기능 개발과 함께 리팩토링 작업의 우선순위를 지정하세요.

- 일관된 코딩 표준: 일련의 코딩 표준이 있으면 팀이 일관되게 코드를 작성하여 더 쉽게 읽고, 이해하고, 유지 관리할 수 있습니다.

- 모듈형 아키텍처: 잘 정의된 인터페이스와 독립적인 구성 요소를 갖춘 모듈형 아키텍처를 사용하여 소프트웨어를 구축하면 수정이 더 쉬워지고 복잡성이 줄어들며 변경이 시스템의 다른 부분에 미치는 영향이 최소화됩니다.

- 최신 기술 사용: 오래된 종속성이나 방법으로 인한 '비트 부패' 기술 부채의 위험을 줄이기 위해 최신 기술과 관행을 최신 상태로 유지합니다.

- 부채 관리를 위한 시간 확보: 스프린트 주기의 정기적인 부분으로 또는 주기적인 '기술 부채 스프린트'를 통해 기술 부채를 해결하는 데 전용 시간을 할당하십시오. 이를 통해 팀은 심각한 부담이 되기 전에 기술 부채를 사전에 해결할 수 있습니다.

마지막으로 기술 부채를 줄이는 데 있어서 AppMaster 와 같은 코드 없는 플랫폼의 역할을 고려해 볼 가치가 있습니다. 이러한 플랫폼을 사용하면 일관성과 자동화된 코드 생성을 촉진하는 동시에 신속한 애플리케이션 개발이 가능합니다. 결과적으로 수동 오류, 오래된 기술, 일관되지 않은 코딩 패턴과 같은 기술 부채의 많은 원인을 제거하는 데 도움이 될 수 있습니다. no-code 솔루션을 활용함으로써 개발 팀은 기술 부채 축적 위험을 최소화하면서 가치와 혁신을 제공하는 데 집중할 수 있습니다.

#### 기술 부채 감소에서 No-Code 플랫폼의 역할

소프트웨어 개발 영역에서 no-code 플랫폼은 기술 부채를 해결하기 위한 강력한 경쟁자로 떠올랐습니다. 이러한 플랫폼은 개발자가 수동으로 코드를 작성할 필요 없이 애플리케이션을 설계, 구축 및 실행하기 위한 시각적 인터페이스를 제공합니다. No-code 플랫폼은 다음과 같은 몇 가지 주요 문제를 해결하여 기술 부채를 줄이는 데 기여할 수 있습니다.

##### 신속한 애플리케이션 개발

No-code 플랫폼은 신속한 애플리케이션 개발을 가능하게 하여 개발자가 소프트웨어를 신속하게 생성하고 수정할 수 있도록 해줍니다. 이러한 속도는 개발자가 프로젝트를 보다 유연하게 테스트, 반복 및 리팩토링할 수 있으므로 시간 제약으로 인해 발생하는 고의적인 기술 부채를 줄일 수 있습니다.

##### 일관성 증진

No-code 플랫폼의 자동화된 코드 생성 기능은 애플리케이션 일관성을 보장하는 데 도움이 됩니다. 사전 정의된 템플릿과 표준화된 구성 요소를 사용하면 중복되고 일관되지 않은 코드의 양이 크게 줄어들어 유지 관리 및 확장성이 쉬워집니다.

##### 수동 오류 제거

no-code 플랫폼은 자동으로 코드를 생성하므로 인적 오류와 의도하지 않은 기술 부채가 발생할 가능성이 크게 줄어듭니다. 자동화된 코드 생성은 수동 코딩 실수로 인해 버그나 불일치가 발생할 가능성을 줄여줍니다.

##### 최신 기술 및 아키텍처 사용

대부분의 no-code 플랫폼은 최신 기술과 아키텍처 패턴을 활용하여 오래된 기술이나 소프트웨어 관행으로 인한 기술 부채 위험을 줄입니다. 이러한 플랫폼은 지속적으로 발전함에 따라 최신 모범 사례와 기술을 통합하여 개발자가 업계 표준을 최신 상태로 유지할 수 있도록 합니다.

##### 모듈식이며 유지 관리가 쉬운 코드 장려

No-code 플랫폼은 일반적으로 자신이 생성하는 애플리케이션에 모듈성과 우려 사항의 분리를 적용합니다. 잘 구조화된 코드를 촉진함으로써 이러한 플랫폼은 장기적으로 애플리케이션을 더 쉽게 유지 관리, 향상 및 확장할 수 있게 하여 기술 부채를 효과적으로 줄입니다.

이러한 기술적 부채 문제를 해결하는 no-code 플랫폼의 한 예는 AppMaster 입니다. 2020년에 설립된 AppMaster 최소한의 코딩 작업으로 웹, 모바일 및 백엔드 애플리케이션을 생성하기 위한 포괄적인 플랫폼을 제공함으로써 60,000명 이상의 사용자 요구 사항을 충족하도록 성장했습니다.

AppMaster 의 주요 기능 중 일부는 다음과 같습니다.

- 데이터베이스 스키마, 비즈니스 로직, REST API endpoints 설계를 위한 시각적 인터페이스

- 웹 및 모바일 애플리케이션을 위한 드래그 앤 드롭 UI 디자인

- 최신 기술 스택을 사용한 자동화된 코드 생성

- 요구 사항이 변경될 때마다 완전한 코드 재생성을 통해 기술 부채 제거

- 신속한 애플리케이션 개발 및 프로토타이핑 지원

소프트웨어 개발 프로젝트에 AppMaster 와 같은 no-code 플랫폼을 선택하면 기술 부채 문제를 크게 완화하고 장애물을 줄이면서 혁신을 주도할 수 있습니다. no-code 및 low-code 솔루션의 채택이 지속적으로 추진력을 얻으면서 이러한 플랫폼이 기술 부채를 완화하고 조직의 소프트웨어 개발 결과를 개선하는 데 어떻게 역할을 할 수 있는지 평가하는 것이 중요합니다.

-  기술 부채 감소에서 No-Code 플랫폼의 역할 

---

## 24. [편리한 객체 간 매핑을 위한 MapStruct 적용기 (feat. SENS) | by NAVER CLOUD PLATFORM | NAVER CLOUD PLATFORM | Medium](https://medium.com/naver-cloud-platform/%EA%B8%B0%EC%88%A0-%EC%BB%A8%ED%85%90%EC%B8%A0-%EB%AC%B8%EC%9E%90-%EC%95%8C%EB%A6%BC-%EB%B0%9C%EC%86%A1-%EC%84%9C%EB%B9%84%EC%8A%A4-sens%EC%9D%98-mapstruct-%EC%A0%81%EC%9A%A9%EA%B8%B0-8fd2bc2bc33b)
> 생성: 2023-10-03

### 편리한 객체 간 매핑을 위한 MapStruct 적용기 (feat. SENS)

#### Ncloud 문자/알림 발송 서비스 SENS 개발 과정에서 MapStruct를 활용해 보았습니다.

NAVER CLOUD PLATFORM

·

Follow

Published in

NAVER CLOUD PLATFORM

·

25 min read

·

Dec 15, 2022

안녕하세요, 네이버 클라우드 플랫폼 (Ncloud) 입니다.

Ncloud의 메시지 알림 서비스 Simple & Easy Notification Service(이하 SENS)를 개발하며 경험한 내용을 공유드립니다.

개발하다 보면 객체 간의 매핑은 거의 필수라고 할 수 있는데요, SENS를 진행하면서도 객체 간 매핑은 피할 수 없었습니다.

SENS 프로젝트는 멀티 모듈로 구성했고, 객체 간 인터페이스를 DTO로 두었습니다. 그러다 보니 각 모듈에서 필요한 객체를 DTO를 이용해 처리하는 경우가 많아졌고, 코드 복잡성도 높아지고 매핑 관리도 어려웠습니다.

이런 상황에서 ModelMapper와 같은 일반적인 매퍼를 사용하면, 매핑에 필요한 로직이 모두 분산되어 매핑이 많아질수록 코드를 관리하기가 힘들었습니다.

코드 복잡성과 관리의 어려움에서 벗어나기 위해 SENS에서는 MapStruct 를 적용해보았는데요. MapStruct를 적용하고 사용한 경험을 공유드립니다.

### MapStruct 란?

MapStruct는 Java bean 유형 간의 매핑 구현을 단순화하는 코드 생성기입니다.

MapStruct의 특징은 아래와 같습니다.

- 컴파일 시점에 코드를 생성하여 런타임에서 안정성을 보장합니다.

- 다른 매핑 라이브러리보다 속도가 빠릅니다.

- 반복되는 객체 매핑에서 발생할 수 있는 오류를 줄일 수 있으며, 구현 코드를 자동으로 만들어주기 때문에 사용이 쉽습니다.

- Annotation processor를 이용하여 객체 간 매핑을 자동으로 제공합니다.

- 다만, Lombok 라이브러리에 먼저 dependency (의존성) 추가가 되어있어야 합니다. MapStruct는 Lombok의 getter, setter, builder를 이용하여 생성되므로 Lombok 보다 먼저 의존성이 선언된 경우 실행할 수 없습니다.

### MapStruct 사용 방법

SENS에서 MapStruct를 사용한 방법입니다. 아래 사용된 코드는 샘플 코드임을 참고 부탁드립니다.

#### 1. 기본 사용방법

MapStruct를 사용하기 위해서는 먼저 dependency (의존성) 추가가 필요합니다.

```plain text
dependencies {
    ...
    implementation 'org.mapstruct:mapstruct:1.5.3.Final'
    annotationProcessor 'org.mapstruct:mapstruct-processor:1.5.3.Final'
    ...
}
```

다만 주의할 점은 MapStruct가 Lombok보다 뒤에 dependency 선언이 되어야 합니다.

MapStruct는 Lombok의 getter, setter, builder를 이용하여 생성되므로 Lombok보다 먼저 dependency가 선언 되는 경우 정상적으로 실행할 수 없습니다.

먼저 API를 통해 메세지를 보낼 body를 받았다고 가정해보겠습니다. 해당 메세지는 아래 RequestDto 에 담겨져 있습니다.

```plain text
public class RequestDto {
        private String title;
        private String content;
        private String sender;
        private List<String> receiver;
        private LocalDateTime requestTime;
        private String type;
}
```

그리고 RequestDto에 담긴 내용을 MessageBodyDto에 매핑하려고 합니다.

```plain text
public class MessageBodyDto {
        private String title;
        private String content;
        private String sender;
        private List<String> receiver;
        private LocalDateTime requestTime;
        private String type;
}
```

이제 매핑을 위한 Interface를 만들어줍니다.

```plain text
@Mapper
public interface MessageMapper {
	MessageMapper INSTANCE = Mappers.getMapper(MessageMapper.class);

         // RequestDto -> MessageBodyDto 매핑
	MessageBodyDto toMessageBodyDto(RequestDto requestDto);
}
```

Mapper 인터페이스에 @Mapper 어노테이션을 붙이면 MapStruct가 자동으로 MessageMapper의 구현체를 생성해줍니다.

위에서 사용된 MessageMapper INSTANCE = Mappers.getMapper(MessageMapper.class)는 매퍼 클래스에서 MessageMapper 를 찾을 수 있도록 하는 방법입니다. 매퍼 interface에서 위와 같이 Instance를 선언해주면 매퍼에 대한 접근이 가능합니다.

매핑하려는 객체는 필드값이 동일하기 때문에, 구현 코드를 작성 또는 수정하지 않고 쉽게 매핑할 수 있습니다.

자동으로 생성되는 구현체는 아래와 같습니다.

```plain text
public class MessageMapperImpl implements MessageMapper {

    @Override
    public MessageBodyDto toMessageBodyDto(RequestDto requestDto) {
        if ( requestDto == null ) {
            return null;
        }

        MessageBodyDto.MessageBodyDtoBuilder messageBodyDto = MessageBodyDto.builder();

        messageBodyDto.title( requestDto.getTitle() );
        messageBodyDto.content( requestDto.getContent() );
        messageBodyDto.sender( requestDto.getSender() );
        List<String> list = requestDto.getReceiver();
        if ( list != null ) {
            messageBodyDto.receiver( new ArrayList<String>( list ) );
        }
        messageBodyDto.requestTime( requestDto.getRequestTime() );
			  messageBodyDto.requestType( requestDto.getRequestType() );

        return messageBodyDto.build();
    }
}
```

매퍼를 위한 interface만 만들면, 매핑이 필요한 객체에 대해 자동으로 구현체를 만들어줍니다. 위 구현체는 빌드 시 build/classes/java/main/에 매핑 인터페이스가 위치한 곳에 만들어지게 됩니다.

지금까지 매핑하고자 하는 컬럼이 동일할 때 매핑하는 방법에 대해 알아보았습니다. 실전에서는 매핑하려는 객체가 단순하지 않은 경우가 있었는데요. 아래에서는 SENS에서 사용했던 다양한 매핑 방법을 설명 드리겠습니다.

#### 2. 매핑에 여러 객체가 필요한 경우

여러 객체를 하나의 객체에 매핑하는 경우입니다.

PageDto와 위에 사용된 RequestDto를 MessageServiceDto에 매핑해보려고 합니다.

```plain text
public class PageDto {
	private Integer pageIndex;
	private Integer pageCount
}
```

```plain text
public class MessageServiceDto {
  private String title;
	private String content;
	private String sender;
	private List<String> receiver;
	private String type;
	private Integer pageIdx;
	private Integer pageCnt;
}
```

```plain text
public interface MessageMapper {
	MessageMapper INSTANCE = Mappers.getMapper(MessageMapper.class);

         //PageDto, RequestDto -> MessageServiceDto 매핑
	@Mapping(source="pageDto.pageIndex", target="pageIdx")
        @Mapping(source="pageDto.pageCount", target="pageCnt")
	MessageServiceDto toMessageServiceDto(PageDto pageDto, RequestDto requestDto);
}
```

매핑하려는 모든 컬럼들이 같다면 별도의 어노테이션으로 표시할 필요가 없지만, 만약 지정해야 하는 경우가 있다면 예시처럼 @Mapping을 이용하여 source에는 매핑값을 가지고 올 대상, target에는 매핑할 대상을 각각 작성해줍니다.

이렇게 코드를 작성하면 매핑할 필드명이 다르거나, 두 객체 간 같은 필드가 있어도 특정 필드를 지정하여 매핑할 수 있습니다.

구현체는 아래와 같이 자동으로 만들어집니다.

```plain text
    @Override
    public MessageServiceDto toMessageServiceDto(PageDto pageDto, RequestDto requestDto) {
        if ( pageDto == null && requestDto == null ) {
            return null;
        }

        MessageServiceDto.MessageServiceDtoBuilder messageServiceDto = MessageServiceDto.builder();

        if ( pageDto != null ) {
            messageServiceDto.pageIdx( pageDto.getPageIndex() );
            messageServiceDto.pageCnt( pageDto.getPageCount() );
        }
        if ( requestDto != null ) {
            messageServiceDto.title( requestDto.getTitle() );
            messageServiceDto.content( requestDto.getContent() );
            messageServiceDto.sender( requestDto.getSender() );
            List<String> list = requestDto.getReceiver();
            if ( list != null ) {
                messageServiceDto.receiver( new ArrayList<String>( list ) );
            }
            messageServiceDto.type( requestDto.getType() );
        }

        return messageServiceDto.build();
    }
```

#### 3. 매핑에 여러 파라미터가 필요한 경우

RequestDto와 여러 가지 다른 인자값이 MessageListServiceDto에 매핑되어야 하는 경우입니다.

```plain text
public class MessageListServiceDto {
	private String messageId;
	private Integer count;
	private String title;
	private String content;
	private String sender;
	private List<String> receiver;
	private LocalDateTime requestTime;
}
```

Mapper Interface를 작성할 때 위에서 작성한 것처럼 작성하되, 필요한 파라미터를 추가로 작성해줍니다.

```plain text
public interface MessageMapper {
	MessageMapper INSTANCE = Mappers.getMapper(MessageMapper.class);

         //messageId, count, requestDto -> MessageServiceDto 매핑
	MessageListServiceDto toMessageListServiceDto(String messageId, Integer count, RequestDto requestDto);
}
```

그러면 MapStruct에서 파라미터를 포함하여 매핑하는 구현체를 자동으로 만들어줍니다.

```plain text
    @Override
    public MessageListServiceDto toMessageListServiceDto(String messageId, Integer count, RequestDto requestDto) {
        if ( messageId == null && count == null && requestDto == null ) {
            return null;
        }

        MessageListServiceDto.MessageListServiceDtoBuilder messageListServiceDto = MessageListServiceDto.builder();

        if ( requestDto != null ) {
            messageListServiceDto.title( requestDto.getTitle() );
            messageListServiceDto.content( requestDto.getContent() );
            messageListServiceDto.sender( requestDto.getSender() );
            List<String> list = requestDto.getReceiver();
            if ( list != null ) {
                messageListServiceDto.receiver( new ArrayList<String>( list ) );
            }
            messageListServiceDto.requestTime( requestDto.getRequestTime() );
        }
        messageListServiceDto.messageId( messageId );
        messageListServiceDto.count( count );

        return messageListServiceDto.build();
    }
```

#### 4. 추가 매핑 방법 with Custom

앞서 설명한 매핑 방법으로는 원하는 만큼 유연하게 매핑할 수가 없는데요. SENS에서는 매핑하는 필드의 타입이 다르거나, default 값을 채워야 한다거나, 매핑되는 구현체를 직접 작성해야 하는 경우가 있었습니다.

이런 상황에서 SENS에서는 어떻게 유연하게 매핑 했는지, 방법을 공유해 드립니다.

> 4-1 매핑 시 default 값 지정

source 객체에 빈 값이 들어오는 경우, NPE 를 피하기 위해, 특정 default 값이 지정되어야 하는 경우 등의 상황에서 defaultValue와 defaultExpression을 이용해서 default 값을 지정할 수 있습니다.

아래 예시에서는 RequestDto를 MessageListServiceDto에 매핑할 때, messageId가 null 인 경우 UUID 값을 default 값으로 채워주는 예시입니다.

```plain text
@Mapper(imports = UUID.class)
public interface MessageMapper {
	MessageMapper INSTANCE = Mappers.getMapper(MessageMapper.class);

        @Mapping(source = "messageId", target = "messageId", defaultExpression = "java(UUID.randomUUID().toString())")
        @Mapping(source = "requestDto.type", target = "type", defaultValue = "SMS")
        @Mapping(source = "requestDto.sender", target="sender", ignore=true)
        MessageListServiceDto toMessageListServiceDto(String messageId, Integer count, RequestDto requestDto);
}
```

> 4-2 매핑 시 특정 필드 매핑 무시

특정 필드를 빼고 매핑해야 하는 경우 ignore 를 사용해 제외할 수 있습니다.

```plain text
@Mapper(imports = UUID.class)
public interface MessageMapper {
	MessageMapper INSTANCE = Mappers.getMapper(MessageMapper.class);

        @Mapping(source = "requestDto.sender", target="sender", ignore=true)
	MessageListServiceDto toMessageListServiceDto(String messageId, Integer count, RequestDto requestDto);
}
```

> 4-3 특정 필드 매핑 시 지정 메소드 이용

이외에 별도 메소드를 매핑에 이용한 방법입니다.

MessageListServiceDto의 type이 아래와 같이 enum으로 변경되고, RequestDto가 MessageListServiceDto에 매핑될 때 type의 데이터 타입이 enum으로 변경되어야 한다고 가정해봅시다.

```plain text
public class MessageListServiceDto {
   private String messageId;
   private Integer count;
   private String title;
   private String content;
   private String sender;
   private List<String> receiver;
   private LocalDateTime requestTime;
   private Type type;
}
```

```plain text
public enum Type {
	SMS("SMS"),
	LMS("LMS"),
	MMS("MMS");

	private String code;

	@Override
	public String toString(){
		return this.code;
	}
}
```

enum class가 위와 같고, mapper에 enum으로 매핑하기 위한 메소드를 작성해줍니다.

```plain text
    @Mapping(source = "requestDto.type", target = "type", qualifiedByName = "typeToEnum")
    MessageListServiceDto toMessageListServiceDto(String messageId, Integer count, RequestDto requestDto);

    @Named("typeToEnum")
    static Type typeToEnum(String type) {
     switch (type.toUpperCase()) {
      case "LMS":
       return Type.LMS;
      case "MMS":
       return Type.MMS;
      default:
       return Type.SMS;
     }
    }
```

qualifiedByName에 매핑할때 이용할 메소드를 지정해주고, 커스텀 메소드에는 @Named()를 이용해 매핑에 이용될 메소드라는 것을 명시해줍니다.

지금까지 qualifiedByName을 사용하여 특정 필드 매핑 시 이용할 메소드를 지정하는 방법을 공유드렸습니다. 참고로 아래와 같이 작성해도 동일하게 동작합니다.

```plain text
default {TargetFieldDataType} To{TargetFieldName} ({SourceFieldDataType} SourceFieldName) {
   ...
}
```

enum 매핑 코드를 qualifiedByName 없이 작성하면 아래와 같이 수정할 수 있습니다

```plain text
MessageListServiceDto toMessageListServiceDto(String messageId, Integer count, RequestDto requestDto);

default Type toType(String type) {
	switch (type.toUpperCase()) {
		case "LMS":
			return Type.LMS;
		case "MMS":
			return Type.MMS;
		default:
			return Type.SMS;
	}
}
```

기본적으로 간단한 enum 매핑을 MapStruct 에서 지원하기도 하며, enum → enum 매핑은 @EnumMapping, @ValueMapping을 통해 매핑할 수 있습니다.

> 4-4 사용자 정의 매퍼 메소드

매핑이 까다로운 경우, MapStruct에서 자동으로 구현되는 매핑 메소드 외에 직접 매핑 메소드를 구현해야 하는 경우가 있습니다.

이런 경우 default를 붙여 메소드를 만들어주면, 구현 메소드 대신 default 로 정의한 메소드를 사용할 수 있습니다.

위에서 사용한 toMessageListServiceDto를 default메소드로 만들어보겠습니다.

```plain text
default MessageListServiceDto toMessageListServiceDto(String messageId, Integer count, RequestDto requestDto) {
   String messageType = Optional.ofNullable(requestDto.getType()).orElse("sms").toUpperCase();
   Type msgType = Type.SMS;

   if (messageType.equals("LMS")) {
      msgType = Type.LMS;
   } else if (messageType.equals("MMS")){
      msgType = Type.MMS;
   }

   return MessageListServiceDto.builder()
      .messageId(Optional.ofNullable(messageId).orElse(UUID.randomUUID().toString()))
      .count(Optional.ofNullable(count).orElse(0))
      .title(requestDto.getTitle())
      .content(requestDto.getContent())
      .sender(requestDto.getSender())
      .receiver(Optional.ofNullable(requestDto.getReceiver()).orElse(Collections.EMPTY_LIST))
      .requestTime(LocalDateTime.now())
      .type(msgType)
      .build();
}
```

아래와 같이 default를 붙여서 매퍼를 사용하면, 위에서 직접 작성한 default 메소드를 매핑 시 사용하게 됩니다.

```plain text
MessageListServiceDto messageListServiceDto = MessageMapper.INSTANCE.toMessageListServiceDto(messageId, count, resDto);
```

### MapStruct Processor 옵션 및 매핑 정책

MapStruct 는 Annotation Processor 를 이용한 매핑인 만큼, Annotation 을 통한 옵션이나, 매핑에 대한 정책을 @Mapper 에 설정할 수 있습니다. 간략하게 MapStruct에서 제공하는 옵션과 정책을 소개하도록 하겠습니다.

#### ComponentModel

매퍼를 빈으로 만들어야 하는 경우, 아래와 같이 설정하면 빈으로 등록할 수 있습니다.

```plain text
@Mapper(componentModel = "spring")
public interface MessageMapper {
	...
}
```

---

## 25. [The Spring Modulith: Monolithic but Manageable | by Ritesh Shergill | Medium](https://medium.com/@riteshshergill/the-spring-modulith-monolithic-but-manageable-ca1532a1e585)
> 생성: 2023-10-03

_(본문 없음)_

---

## 26. [역량만 있어선 안 된다… IT 프로젝트가 여전히 실패하는 8가지 이유](https://www.ciokorea.com/news/311246)
> 생성: 2023-10-25

IT 및 비즈니스 리더의 전략적 연계에도 불구하고, 기술 및 혁신 이니셔티브는 여전히 많은 실패를 겪는다. IT 부서가 실수로부터 교훈을 얻는 방법을 소개한다.

ⓒ Getty Images Bank

IT 부서는 과거 프로젝트 운영 프로세스를 괴롭혔던 문제에서 벗어나기 위해 부단히 노력해 왔다. 이전과 같은 대규모 실패를 피하기 위해 범위 확장, 폭포수 방법론(Waterfall Methodology), 반복 개발을 위한 긴 타임라인, 애자일 접근 방식, 멀티위크 스프린트 등의 업무 방식을 도입해 왔다.

이러한 변화가 실제로 도움이 되긴 했지만, 여전히 많은 IT 프로젝트가 실패하고 있다.

프로젝트 실패는 이제 수십 년 전처럼 IT 환경 전체를 무너뜨리는 것을 의미하지 않는다. 일반적으로 새 시스템이 작동하지 않아 완전히 폐기해야 하는 경우도 드물다.

CIO, 프로젝트 리더, 연구원 및 IT 컨설턴트에 따르면 오늘날의 실패는 조직이 기대한 수준의 이점을 IT 프로젝트가 일부 또는 전부 제공하지 못했다는 의미에 가깝다. 실패는 프로젝트가 수익을 창출하지 못하거나, 완료 시기가 너무 늦어 쓸모없게 되거나, 참여를 유도하지 못해 사용자가 프로젝트를 외면하게 되는 것을 의미할 수도 있다.

몽클레어 주립대학의 부교수이자 프로젝트 관리 전문가(PMP)인 테 우는 “오늘날 애자일이 발전하면서 ‘실패’의 정의가 달라졌다”라고 말했다. 다시 말해 이제 IT 프로젝트 실패는 기술적 재해라기보다는 목표 시점을 놓친 것에 더 가깝다.

몇몇 연구 결과가 이를 뒷받침한다. KPMG의 ‘2023 기술 설문조사’에 따르면 미국 기술 임원 400명 중 51%가 지난 2년 동안 디지털 혁신 투자를 통해 성과나 수익성이 증가하지 않았다고 답했다.

IT 프로젝트 실패율에 대해 일관적인 설문조사 및 연구 결과는 없지만, 많은 연구자들은 IT 프로젝트가 기대에 미치지 못하는 비율이 계속 높아지고 있다고 보고 있다. 그렇다면 무슨 일이 일어나고 있는 걸까? IT 프로젝트가 계속 실패하는 이유는 뭘까? 몇 가지 일반적인 원인을 살펴볼 수 있다.

1. 프로젝트 관리 전문성 부족

직원들은 종종 추가 업무를 맡는다. 때로는 IT 직원이 프로젝트를 이끌어야 하는 경우도 있다.

직원들이 프로젝트 관리자(PM) 역할을 수행한다고 해서 전문 지식, 교육 또는 경험이 제대로 갖춰진 것은 아니다. 프로젝트를 관리하거나 추가 프로젝트 관리 작업을 완수하는 데 필요한 사항을 학습할 시간도 충분히 주어지지 않는다.

몬타나 대학의 CIO인 잭 로스밀러는 “조직은 아무 교육도 받지 않은 사람이 프로젝트를 운영할 수 있다고 기대한다. 또는 풀타임으로 다른 일을 하는 관리자에게 프로젝트 관리까지 맡기기도 한다”라고 말했다.

로스밀러는 자신이 속한 IT 부서에서 이러한 접근 방식을 취하면 어떤 결과를 초래하는지 알고 있다고 말했다. 그는 “과거 수백 개의 서로 다른 프로젝트가 진행돼야 했을 때, 조직은 관리자가 이를 효율적으로 관리하며 운영할 것으로 기대했다. 프로젝트 관리를 전담하는 부서가 있었다면 훨씬 더 나은 성과를 거둘 수 있었을 것이다”라고 전했다.

로스밀러는 최근 IT 부서에 프로젝트 관리자 2명을 고용해 문제를 해결하고 있다. 로스밀러는 숙련된 프로젝트 관리 전문가가 합류한 뒤 개선 효과가 나타나고 있으며, 특히 수고를 줄이고 프로젝트 배포를 더 효율적으로 하는 데 도움이 되고 있다고 설명했다.

그는 숙련된 프로젝트 관리자가 리소스를 모으고 일정을 조정하고 직원 일정을 조율하고, 모두가 같은 방향으로 나아가도록 유도하는 데 더 능숙하며, 여러 프로젝트에 걸쳐 이를 수행할 수 있기 때문이라고 말했다. 그에 따르면 프로젝트 관리자는 프로젝트가 예상 목표를 달성하기 위해 필요한 거버넌스를 구현할 수 있으며, 범위 내 비용과 일정이 늘어나지 않도록 하는 데 더 능숙하다.

2. 경영진의 지원이 거의 또는 전혀 없는 경우

IT 프로젝트를 방해하는 또 다른 문제는 최고 경영진의 무관심이다. 베테랑 프로젝트 리더들은 이러한 시나리오가 생각보다 자주 발생한다고 말했다.

프로젝트 관리 전문가이자 PMI의 북미 지역 운영 관리자인 칼라 아이뎀은 “회의나 프로젝트 현황 보고에서 경영진이 ‘왜 이 일을 하는가’라고 물은 적이 있다. 우리가 가려는 방향의 중요성을 제대로 이해하지 못한 것이다”라고 말했다.

아이뎀은 프로젝트에 비즈니스 스폰서가 있는 경우에도 경영진의 지원이 부족할 수 있으며, 이는 해당 프로젝트가 특정 부서의 우선순위일지라도 조직의 목표와는 일치하지 않음을 시사한다고 말했다.

이러한 경우에는 재조정할 필요가 있다.

그는 “경영진에게 물어봐야 할 수도 있다. ‘여러분 앞에 놓인 모든 사실을 고려할 때 이 프로젝트를 진행해야 할까요, 아니면 하지 말아야 할까요?’ 때로는 어떤 이유로 인해 진행할 수 없는 경우도 있지만, 결정을 내려야 한다”라고 말했다. 그는 경영진의 지원이 자금, 인력, 관심 자원을 확보하는 수단이기 때문에 성공에 매우 중요한 요소라고 덧붙였다.

3. 비즈니스 스폰서의 무책임

마찬가지로 프로젝트의 스폰서가 기술 프로젝트 성공에 대한 책임을 지지 않고 IT 부서에 모든 부담을 떠넘기면 프로젝트가 실패로 끝날 수 있다.

테 우는 “훌륭한 프로젝트 리더십은 비즈니스 사례를 만들어 본 사람이 스폰서가 돼 프로젝트가 현실적으로 수행되는지 확인하고, 지지자가 돼 주는 것에서 시작한다”라고 말했다.

경영진과 같은 비즈니스 스폰서는 프로젝트의 사업적인 이유를 명확히 하고, 예상되는 장점을 설정하고, 목표를 달성하기 위해 리소스를 모으는 데 중요한 역할을 한다. 또한 이들의 지원은 직원들에게 프로젝트 중요성을 알리는 신호가 되기 때문에, 신기술 채택과 관련 프로세스 변경을 촉진하는 데 도움이 된다고 테 우는 덧붙였다.

4. 비즈니스 스폰서의 참여 부족

비즈니스 스폰서는 지원과 정보를 제공하며 장애물과 병목 현상을 제거하고, 문제를 제기해 신속하게 해결할 수 있도록 돕고, 성공을 지지해 앞으로의 변화에 대한 추진력과 흥미를 높일 수 있다고 아이뎀은 말했다.

스폰서가 제 역할을 하지 않으면 이러한 이점도 사라진다. 아이뎀은 그런 일을 실제로 겪었다고 말했다.

한때 그녀는 복잡한 다중 위치 소프트웨어 구현 작업을 꾸준히 진행하고 있었다. 다음 단계를 위해 지역 부서를 한데 모아야 했고, 스폰서의 도움을 받아야 했다. 하지만 스폰서는 문제 해결에 참여하지 않았다. 일부 운영 부서는 무슨 일이 일어나는지 알 수 없었고, 일부는 왜 참여해야 하는지 이해하지 못했다.

아이뎀은 “정보가 순차적으로 전달되지 않고 일부 영역에서 반발이 있었다”라고 말하며, 이러한 상황이 프로젝트의 추진력을 위태롭게 했다고 전했다.

아이뎀은 스폰서가 다른 큰 이슈로 인해 프로젝트에서 멀어졌으며, 그 결과로 관련 지역에 프로젝트 정보를 전달하는 데 제대로 주의를 기울이지 않았다고 언급했다. 그녀는 “스폰서가 프로젝트에 집중해야 할 때 다른 우선순위가 너무 많았다. 그래서 분명히 해야 했다. 조직으로서 이 프로젝트가 최우선 순위라고 분명히 말해야 했다”라고 전했다.

프로젝트가 무산되는 것을 막기 위해 아이뎀은 후원자와 더 많은 일대일 미팅을 예약해 관계를 강화했다. 또한 프로젝트 요구 사항에 대해 더 직접적으로 소통할 수 있도록 해 후원자가 다시 집중하고 프로젝트를 이어나갈 수 있도록 했다.

5. 모든 이해관계자가 참여하지 않을 때

IT 프로젝트 관리자 크리스타 필립스는 어느 다국적 대기업이 회사 전체에 신기술을 구현했으나 진행 중인 작업을 한 부서에서 전혀 인지하지 못했던 사례를 언급했다. 특정 부서가 모든 계획 및 프로젝트 프로세스에서 제외된 사례다.

필립스는 “프로젝트 리더가 어떻게 놓쳤는지는 모르겠지만, 한 부서를 완전히 놓쳤다. 그래서 시스템이 가동됐을 때 해당 부서 직원들은 ‘이게 뭐야’라고 생각했다. 이로 인해 프로젝트의 기회를 일부 누락했다”라고 말했다.

필립스는 프로젝트 부서가 일반적으로 전체 부서를 간과할 일은 없지만, 프로젝트 프로세스에 포함해야 하는 이해관계자를 전부 식별하고 포함하지 못하는 경우도 있다고 말했다. 그러면 중요한 요구 사항, 고려해야 할 규정, 활용 기회를 놓칠 가능성이 있다. 필립스는 콜로라도 PMI의 파이크스 피크 지역 지부 회장을 맡고 있다.

6. 리소스가 충분하지 않거나 올바르지 않은 경우

일부 프로젝트 리더는 오늘날 IT 프로젝트가 실패하는 또 다른 이유로 ‘더 적은 비용으로 더 많은 성과를 내야 한다’는 기대치가 만연한다는 점을 꼽았다. 이 사고방식은 프로젝트 부서가 작업을 제시간에 완료하는 데 필요한 리소스를 부족하게 만든다.

필립스는 “모두 수익에 대해 신경을 기울이고 있다. 그 이면에는 소수의 사람이 많은 일을 하기를 기대하는 측면도 있다”라고 언급했다.

필립스에 따르면 직원이 여러 프로젝트에 동시에 배정되는 경우가 많으며, 기존 업무에 더해 프로젝트 업무까지 맡는 경우도 있다. 그렇게 되면 직원들은 업무에 집중하지 못하고 여러 방향으로 끌려 다니게 된다.

어떤 이들은 프로젝트 관리자가 성공에 필요한 비용, 인재, 시간을 과소 할당할 경우 어떤 결과가 초래되는지 잘 알고 있으면서도, 기업 리더가 비용과 작업 완료에 필요한 시간을 과소평가하거나 적절한 인재를 팀에 할당하지 않는다고 말하기도 한다(교육을 받지 않았거나 경험이 없는 직원이 업무에서 필요한 기술을 습득할 것이라고 생각한다).

노련한 프로젝트 리더들에 따르면, IT 프로젝트 관리자와 CIO는 후원자와 최고 경영진이 필요 리소스, 자원 및 일정에 대해 현실적인 정보를 얻을 수 있도록 지원해야 한다. 하지만 이는 상당히 까다로운 작업일 수 있다.

이를 위해서는 포트폴리오 관리 프로그램을 구현해 현재 진행 중인 작업에 대한 가시성을 확보하고, 리소스를 과소 할당할 수 있는 프로젝트 사일로를 허물어야 한다고 프로젝트 리더들은 조언했다.

테 우는 “포트폴리오 관리에 중점을 두면 생산성 문제는 상당 부분 해결할 수 있다. 더 적은 일을 하면서도 제대로 해내는 것, 이것이 포트폴리오 관리의 핵심이다”라고 말했다.

7. 대면 협업의 부족

테 우에 따르면 원격 근무로의 전환은 프로젝트 작업을 전 세계로 확장할 수 있는 가능성을 불러왔지만, 가상 업무 환경은 프로젝트 운영에 있어 몇 가지 문제점을 야기할 수 있다.

그는 우선 조직에서 더 어려운 문제를 해결할 때 비대면 근무 부서가 모이는 데 어려움을 겪는다는 사실을 발견했다. 그는 “모듈 작업을 처리하는 데 있어서는 가상 환경이 좋다고 생각한다. 하지만 크고 복잡한 문제를 해결할 때는 ‘줌’을 통해 할 수 있는 일이 많지 않다”라고 전했다.

그는 또한 일부 부서가 가상 업무 환경에서 유대감을 형성하는 데 어려움을 겪는 것을 봤다면서, “(비대면 근무로 인해) 인간적인 유대감을 희생하게 된다”라고 덧붙였다.

따라서 작업 시간은 더 길어질 수 있으며, 얼굴을 맞대고 일하면 한 시간에 해결할 수 있는 문제가 가상 환경에서는 90분이 걸린다고 테 우는 말했다. 또한 팀이 물리적으로 한 공간에 있을 때는 빠르고 원활하게 진행되던 핸드오프도 가상 환경에서 조율하기에 많은 시간이 소요될 수 있다.

그는 “사람들은 동일한 효율성을 얻기 위해 더 많은 시간을 소비하고 있으며, 인간 관계가 소원해지기 시작한 것 같다”라며, 특히 신입 직원들이 롤 모델이나 본받을 만한 업무 패턴을 지켜보는 것처럼 사무실에서 이뤄지는 비공식적 멘토링 및 학습 기회를 놓칠 수 있다고 지적했다.

그는 이러한 역학 관계로 인해 ‘협업과 소통을 위해 훨씬 더 많은 업무와 시간을 투자하는’ 프로젝트 관리자에게 더 많은 업무가 가중된다고 말했다. 이 문제에 대해 아직 해결책을 찾지 못했다고 그는 덧붙였다.

8. 단절된 핸드오프

프로젝트가 프로덕션으로 전환되고, 프로젝트 관리자가 자리를 옮기고, IT 이니셔티브가 가치를 발휘할 것으로 기대받는 시점이 있다.

테 우는 조직이 이 단계에 있을 경우 프로젝트와 프로젝트에 남아있는 문제가 제대로 관리되지 않으며, 이것이 책임 분담의 단절로 이어져 실패를 낳는다고 지적했다.

그는 “만약 비즈니스 사례가 한 당사자가 되고, 프로젝트 관리자가 다른 당사자를 자처하며, 프로젝트의 비즈니스 사례와는 더 멀리 떨어진, 프로젝트의 결과를 관리하는 이들이 또 다른 당사자가 된다면 연결이 얼마나 단절돼 있는지 볼 수 있다”라고 말했다.

이러한 단절은 기회를 놓치고, 잘못된 방향으로 가고, 어긋난 의사 소통으로 이어져 최종 결과물이 차선책에 그치게 할 수 있다.

그는 애자일과 데브옵스(DevOps) 방법론을 사용하는 조직에서도 단절은 발생할 수 있다고 언급하며 “이는 한 쪽에서 다른 쪽으로 물을 운반하는 다른 방법일 뿐이다. 데브옵스는 변화를 빠르게 처리할 수 있지만, 그 변화가 올바른 변화인지, 투자수익(ROI)을 충분히 제공하는지 여부를 확인하는 것은 다른 문제다”라고 설명했다.

테 우를 비롯한 전문가는 이러한 상황에 대응하기 위해, 프로젝트 작업은 물론 구현 및 채택 단계 전반에 걸쳐 프로젝트의 비즈니스 사례와 결과물을 지속적으로 연결하는 관리 역량과 강력한 프로젝트 거버넌스가 필요하다고 말했다.

---

## 27. [개발자가 "No"라고 말할 때 물어봐야 할 4가지 질문 | GeekNews](https://news.hada.io/topic?id=13333)
> 생성: 2024-02-13

_(본문 없음)_

---

## 28. [OROR Forge: Figma to Code 도구 제작기 (1) 디자인을 코드로 만들어보자! – tech.kakao.com](https://tech.kakao.com/2024/01/09/ororforge-1/)
> 생성: 2024-04-12

2022_blind agile ai android Backend blind-recruitment career client cloud coding coding test conference Data developer developer relations devops event front-end frontend get-server growth ifkakao internship ios javascript kafka kakao kakaokrew kakaotalk kubernetes machine-learning meetup new-krew onboarding opensource preview recap recruitment review seminar server tech techmeet Techtalk test

안녕하세요, OROR 프론트엔드 팀의 테오입니다! 이번 글에서는 프론트엔드 개발에서 빼놓을 수 없는 중요한 부분, 바로 를 해보려고 합니다. 화면을 만드는 프론트엔드 개발자에게 이 코드 변환 과정은 필수적인데, 언뜻 간단해 보일 수 있지만 실제로는 상당한 시간과 노력이 필요한 작업입니다. 이러한 작업의 복잡성을 줄이고자, 저희는 ‘Figma to Code‘라는 새로운 기술적 접근 방식과 그 기능을 제공하는 ‘OROR Forge’라는 도구를 개발하고 있습니다.

아직도 개발이 진행 중인 단계이지만, 이번 글을 통해 그동안 저희가 직면했던 문제들과 이를 해결하기 위한 과정들을 독자분들과 공유하고자 합니다. 저희의 경험을 공유함으로써, 독자분들이 코드 변환 도구를 구현한 과정에 대해 더 깊이 이해하고, 저희가 발견한 해결책에서 유용한 인사이트를 얻을 수 있기를 바랍니다.

#### 전통적인 프론트엔드 개발의 복잡성

##### 퍼블리싱과 마크업

화면을 만드는 프론트엔드 개발 과정에는 필연적으로 디자인을 코드로 변환하는 작업, 즉 ‘퍼블리싱’이나 ‘마크업’ 과정이 포함됩니다. 정적인 이미지 형태로 된 디자인은 데이터 변경이나 콘텐츠 조정에 한계가 있어, 화면 크기나 내용 변경에 따른 동적인 반응이 어렵습니다. 그렇기에 개발자는 디자인을 이미지 그대로 사용하지 않고 코드로 바꾸는 작업을 통해 동적인 컨텐츠를 제공할 수 있도록 해야 합니다.

이 과정에서 우리는 디자인을 정확하게 코드로 옮겨내야 하는데, 전통적으로는 이는 모두 수동으로 코드로 전환해야 하는 복잡한 작업이 요구됩니다. 그리고 여기서 수많은 문제가 발생합니다.

##### 디자인을 코드로 변경하는 과정의 어려움

프론트엔드 개발에서 디자인을 코드로 변환하는 과정은 필수적이지만, 이 과정에서는 아래와 같은 여러 어려움이 존재합니다.

1. 수동 HTML/CSS 마크업의 복잡성: 이 작업은 각 요소를 구현하는 과정은 난이도가 높지 않을 수 있지만, 요소들이 모이면 보통 어마어마한 작업량이 요구되므로 결국 많은 시간이 소요되며, 실수가 발생하기 쉽습니다.

1. 디자인의 정확한 전환 문제: 특히, 위와 같은 실수가 아니더라도 개발자가 종종 디자이너가 구상한 디자인의 일부를 누락하거나 오해할 수 있습니다. 이는 디자인의 섬세한 부분을 개발자가 완전히 이해하지 못했거나 간과할 때 주로 발생합니다(“???: 여기 2px이 틀어졌어요!”).

1. 커뮤니케이션 비용의 증가: 결국 이러한 디자이너와 개발자 간의 작업 불일치로 인해, 추가적인 검수와 조정이 필요합니다. 때문에 서로 간의 작업이 종속관계가 되며, 이는 결과적으로 프로젝트의 진행속도와 효율성이 저하되는 요인이 됩니다.

1. 지속적인 관리와 조정으로 효율성 저하: 디자인이 변경될 때마다 새로운 마크업을 작성해야 하며, 이는 1 ~ 3번의 문제가 다시 발생하는 결과를 초래합니다. 또한, 프로젝트가 진행되는 동안 지속적인 관리와 조정이 필요하게 되어, 프로젝트 관리 측면에서도 효율성이 떨어질 수 있습니다.

이러한 문제들은 프론트엔드 개발 과정에서 상당한 시간과 노력을 쏟게 하고, 개발자와 디자이너 모두에게 부담을 주는 요소들입니다. 특히 현재 구현 중인 프로젝트가 디자인 시안을 많이 만들어보고 이를 변경을 해야 하는 과정에 있다면 더욱더 체감이 되는 문제들입니다.

결국 프로젝트 전체 복잡도와 구현 비용을 낮추기 위해서는, 디자이너와 개발자 모두에게 효율적인 방법을 모색하는 것이 꽤 중요하다는 것을 생각해 볼 수 있습니다.

##### 특히 우리에게 더 Figma to Code가 필요했던 이유

당시 저희 팀은 신규서비스를 개발한 후 런칭한 지 얼마 지나지 않았던 상황이었고, 위에서 말씀드린 문제들을 겪으며 이를 해결할 수 있는 해법이 절실했습니다. 저희 팀에게 ‘Figma to Code’가 특히 필요했던 이유는 아래와 같습니다.

1. 런칭 이벤트와 프로모션: 새로운 서비스 런칭으로 홍보 및 이벤트성의 일회성 페이지가 다수 필요했습니다.

1. 다수의 뷰 개발 필요성: 추가적인 기능 개발 과정 특성상 많은 뷰의 동작을 실험해야 했습니다.

1. 빠른 개발과 협업 프로세스: 그 과정에서 기획, 디자인 그리고 개발 조직 간의 빠른 협업이 요구되었습니다.

1. 지속적인 디자인 변경: 실험적인 접근 과정에서 발생하는 잦은 디자인 변경에도 개발 과정의 효율성 유지하는 것이 중요했습니다.

이러한 상황에서 전통적인 방식으로는 디자인을 화면으로 만드는 시간과 노력이 과도하게 소요되었습니다. 따라서, 자동으로 Figma의 디자인을 코드로 정확하게 변환하여, 디자인 변경에 빠르게 대응하고 프로젝트 전체의 효율성을 높일 수 있는 ‘Figma to Code’ 기능이 어느 때 보다 필요한 상황이었습니다.

#### 상용 Figma to Code 기술 검토

저희 팀은 먼저, 상용에서 사용 가능한 다양한 ‘Figma to Code’ 도구들을 살펴보았습니다. Figma to Code Plugin, Anima Studio, builder.io 등 여러 옵션을 고려한 끝에, Amplify Studio와 Locofy를 주목했습니다.

##### Amplify Studio

Amplify Studio는 Amazon이 개발한 도구로 Figma 파일에서 직접 디자인 요소를 추출해 자동으로 디자인 시스템을 구축할 수 있습니다. 이 서비스의 핵심적인 특징은 아래와 같습니다.

- 디자인 시스템 자동화: Figma 파일에서 컴포넌트를 추출하여 자동으로 디자인 시스템을 구성합니다. 이는 개발자의 수작업을 줄여주는 중요한 기능입니다.

- 컴포넌트 중심 설계: 사용자가 디자인을 모듈화 된 방식으로 관리할 수 있도록, 컴포넌트 중심으로 작동합니다.

##### Amplify Studio의 장점 및 주목할 만한 특징

Amplify Studio는 Figma 디자인을 코드로 변환하는 것 이상의 기능을 제공하고 있습니다. 주요 장점 및 특징은 아래와 같습니다.

- CLI(Command Line Interface) 지원: 강력한 자동화와 통합 기능을 제공하여, 개발 과정을 효율적으로 만듭니다.

- 데이터 바인딩 기능: 데이터와 UI 컴포넌트 간 연동이 용이하여, 동적인 웹 애플리케이션 개발에 유용합니다.

- 기능 연동 및 확장성: AWS(Amazon Web Services)와의 통합을 통해 백엔드 기능과의 연동이 가능하며, 확장 가능한 애플리케이션 구축을 지원합니다.

- 사용자 인터페이스 개선: 개발자와 디자이너 모두에게 편리한 작업 환경을 제공합니다.

Amazon은 Amplify Studio의 이러한 기능들을 통해, 이 제품이 단순한 코드 변환 도구를 넘어 프론트엔드 개발의 전반적인 생산성을 높이는 강력한 솔루션이 될 수 있도록 했습니다.

##### Amplify Studio의 한계점

다만 실제 사용 경험에서 Amplify Studio는 아래와 같이 몇 가지 중요한 제약 사항이 있었습니다.

1. 컴포넌트 제한성: 주로 컴포넌트 중심으로 작동하므로, 컴포넌트가 아닌 다른 디자인 요소의 처리에 제한이 있었습니다.

1. 실제 사용성 문제: 일부 페이지에서 디자인이 제대로 반영되지 않거나 화면이 깨지는 현상이 발생했습니다.

1. 용량 제한의 문제: 큰 용량의 디자인 파일 처리에 제한이 있어, 대규모 프로젝트에는 적용하기 어려웠습니다.

이러한 한계에도 불구하고, Amplify Studio의 부가적인 기능들은 매우 인상적이었습니다. 이러한 기능들은 추후 OROR Forge의 컴포넌트 바인딩 기능을 구현하는 데 영감을 주었습니다.

그러나 전체적인 기능들을 사용해 본 경험으로는 실제 프로젝트 환경에 Amplify Studio를 사용하기에는 여러 면에서 부족함을 느꼈습니다.

##### Locofy

저희 팀은 주목할 만한 또 다른 도구인 Locofy에 대해서도 검토를 진행했습니다. Locofy는 Figma 플러그인과 자체 빌더를 통해 Figma 디자인을 웹용 코드로 생성하는 도구입니다.

##### Locofy의 특징

Locofy의 특징은 아래와 같았습니다.

- Figma 플러그인과 자체 빌더: Figma 디자인을 직접적으로 웹용 코드로 변환할 수 있는 기능을 제공합니다.

- 높은 퀄리티의 코드 생성: 실제 디자인과 거의 유사한 수준의 결과물을 제공하며, 생성된 코드의 퀄리티가 높습니다.

##### Locofy의 장점

Locofy는 특히 디자인을 코드로 변환하는 과정에서 높은 정확성을 보여주었습니다. 또한, Locofy의 추가적인 주요 장점들은 아래와 같았습니다.

1. 디자인 정확도: Figma 디자인을 HTML과 CSS 코드로 변환하는 과정에서 높은 정확도를 제공합니다. 이는 프론트엔드 개발 과정에서 아주 중요한 요소입니다.

1. 코드 퀄리티: 생성된 코드의 퀄리티가 우수하여, 실제 개발 환경에 적용하기 적합합니다.

1. 직관적인 사용성: Figma 플러그인과 자체 빌더의 조합으로 사용자에게 직관적이고 편리한 작업 환경을 제공합니다.

##### Locofy의 한계점

그러나 Locofy를 사용하는 과정에서 몇 가지 아쉬운 점들을 발견했습니다.

1. 가끔씩 디자인과 다른 결과물 생성: Locofy는 준수한 결과물이 생성되는 여러 가지 기능들을 잘 제공하지만, 가끔씩 결과가 틀어지는 경우나 실수가 발생할 수 있습니다.

1. 이벤트 바인딩과 프로퍼티 유지의 어려움: 디자인 변경 시 클릭 이벤트, 바인딩, 프로퍼티 등이 유지되어야 하는데, 이를 처리하는 과정에서의 UI가 상당히 불편했습니다. 언젠가는 개선이 될 문제이지만 플러그인에서 원하는 노드를 선택할 수 있는 기능이 아직까지 제공하지 않고 있기에, 플러그인을 끄고 피그마에서 선택하고 다시 플러그인을 켜서 작업하는 과정에서 상당한 불편함을 가지고 있습니다.

1. 지속적인 유지보수의 어려움: 위와 같은 이유들로 디자인이 변경되었을 때, 생성된 코드를 그대로 적용하기가 어려웠습니다.

이러한 한계점에도 불구하고, Locofy는 전반적으로 우수한 툴이었습니다. 특히 다른 도구와 비교했을 때, 디자인을 코드로 변환하는 과정에서 만들어지는 코드의 퀄리티가 우수한 장점을 보여주었습니다.만일 저희 팀에게 주어진 선택지가 상용 도구를 쓰는 것 밖에 없었다면 저는 아마도 Locofy를 선택했을 것 같습니다.

다만, Locofy는 범용적인 도구의 성격을 지니고 있었기 때문에, 저희 팀의 특수한 요구사항과 상황에는 완전히 부합할 수는 없었습니다. 저희는 이처럼, 두 제품의 벤치마킹을 통해서 저희 팀의 특정 요구사항에 더 정확히 일치하는 ‘Figma to Code’ 솔루션을 만들기 위해, 검토를 계속 진행하였습니다.

#### OROR Forge: 전략과 목표

“디자인의 정확성을 최우선으로 하는 실전용 코드 생성 도구”

당시 OROR 팀에서는 이벤트 및 프로모션과 같은 싱글 페이지 형태의 뷰를 다수 제작해야 하는 경우가 많았습니다. 이러한 페이지들은 기능적 요구사항보다는 디자인의 정확성과 시각적 요소들이 제대로 표현되는 것이 중요합니다. 따라서, 디자인이 변환된 코드가 원본 디자인과 정확히 일치하도록 하는 것이 OROR Forge 툴의 주요 목표가 되었습니다.

다시 말하면, 저희 팀의 과제는 사용 중인 Figma의 디자인을 그대로 정확한 화면 코드로 만들어 낼 수 있는 ‘픽셀 퍼펙트한 코드(Pixel Perfect Code)’를 생성하면서도, 그 생성 결과가 실 서비스에도 사용할 수 있도록 퀄리티 있는 코드를 만들어내는 것이었습니다. 또한, 별도의 추가적인 작업 없이 디자인 변경 시 페이지를 서비스에 반영될 수 있도록 하는 것이었습니다.

위와 같은 목표를 달성하기 위해, 저희 팀에서는 실전에서 변환 코드를 바로 적용 가능하고 디자인의 정확성을 보장하는 OROR Forge를 개발하게 되었습니다.

##### 핵심 목표

저희 과제의 주요 목표를 세부적으로 설명하면 아래와 같습니다.

1. 픽셀 퍼펙트한 코드 생성: 디자인 화면과 정확히 일치하는 형태로 코드를 생성하는 것이 중요했습니다. 디자인의 정확한 전환을 보장함으로써, 개발자들이 생성된 코드에 대한 의심 없이 프로젝트에 집중할 수 있다는 것이 중요했습니다.

1. 사내 프로젝트에의 적용 가능성: 생성된 코드를 회사 프로젝트에 바로 적용할 수 있는 실전성을 보장하는 퀄리티 있는 코드를 만들어 내고, 배포 및 툴을 사용하는 개발 과정에서 효율성을 높입니다.

1. 비즈니스 로직과 디자인의 분리: 디자인 변경 시 비즈니스 로직에 영향을 주지 않도록, 바인딩 관련 코드의 수정 없이도 디자인을 변경할 수 있어야 합니다.

##### 추가적인 목표

또한, 추후에 보다 많은 요구사항을 만족할 수 있도록 아래와 같은 추가 목표들도 함께 고려해 보았습니다.

1. 편리한 설정을 위한 Preview 및 디자인 계층 뷰 제공: 사용자가 설정을 보다 쉽게 할 수 있도록 프리뷰 및 디자인 계층 뷰를 통한 편의성을 제공합니다.

1. 다양한 인터랙션 컴포넌트 제공: 사용자 경험을 풍부하게 만들어줄 다양한 인터랙션 컴포넌트를 제공합니다.

1. 컴포넌트 Props Interface 관리: 컴포넌트의 속성을 효율적으로 관리할 수 있는 인터페이스를 제공합니다.

1. 다양한 이벤트 바인딩 지원: onClick 이벤트뿐만 아니라 다른 모든 이벤트 바인딩을 지원하여, 보다 다양한 상호작용을 구현할 수 있도록 합니다.

1. 외부 모듈 및 컴포넌트 활용 지원: 다양한 외부 모듈과 컴포넌트를 효율적으로 통합하고 활용할 수 있는 방법을 제공합니다.

#### Figma 플러그인을 통한 HTML/CSS 코드 생성

저희 OROR 프론트엔드 팀은 Figma 디자인을 효율적으로 HTML/CSS 코드로 변환하는 방법을 모색하며, Locofy와 같이 Figma 플러그인 방식으로 해당 기능을 제공하고자 했습니다.

##### Figma 플러그인의 개념

Figma 플러그인은 Figma가 제공하는 API를 활용하여 개발자들이 원하는 기능을 구현할 수 있게 해주는 강력한 도구입니다. 최근에는 개발자들이 개발 과정에서 Figma를 많이 활용하게 되면서 작업을 도와주는 플러그인들이 다수 등장하고 있습니다.

또한, Figma 플러그인은 웹 생태계에 기반을 두고 있어 자바스크립트를 활용하여 다양한 기능들을 구현할 수 있습니다. 이는 웹 프론트엔드 개발자가 많은 저희 팀이 플러그인을 수월하게 개발할 수 있는 훌륭한 기반이 되었고, 저희는 Figma 플러그인 생태계의 이러한 장점을 활용하여 사용자에게 친숙하고 효율적인 도구를 제공하고자 했습니다.

##### HTML/CSS 코드 생성

Figma에서 HTML과 CSS 코드를 추출하는 방법은 아래와 같습니다.

1. 노드 선택 및 속성 추출: Figma 디자인의 기본 단위인 노드를 선택하고 각 노드의 속성을 분석합니다. 노드 타입에는 프레임 노드, 텍스트 노드, 벡터 노드 등이 있으며, 각각 다양한 속성을 가지고 있습니다.

1. DOM으로의 변환: Figma 노드를 웹의 DOM 요소로 변환하고 필요한 속성들을 CSS 스타일로 추출합니다. 이 과정을 통해 Figma 디자인을 실제 웹 환경에서 사용할 수 있는 HTML/CSS 코드로 변환합니다.

1. 픽셀 퍼펙트한 코드(Pixel Perfect Code) 목표: Figma의 디자인 요소와 속성을 CSS의 개념과 속성으로 정확하게 대체할 수 있도록 합니다. 이는 ‘픽셀 퍼펙트’ 한 HTML/CSS 코드를 생성하는 것을 목표로 합니다.

##### 디자인과 코드의 정확한 매칭

우리의 목표는 Figma 디자인과 코드가 정확히 일치하는 것이었습니다. 이를 위해, Figma의 디자인 개념과 속성을 깊이 있게 연구하고, 이를 CSS로 올바르게 변환하는 방법을 탐구했습니다. 이러한 접근은 추후 Figma 디자인의 복잡한 요소들을 정확하고 효율적으로 웹 환경에 구현할 수 있게 해 주었습니다.

이제 본격적으로 아래의 내용들을 통해, Figma 플러그인을 활용하여 HTML/CSS 코드를 생성하는 방법과 Figma 디자인을 웹 코드로 정확히 변환하는 과정을 설명드리겠습니다. 이러한 과정을 하나씩 살펴보며 독자분들이 프론트엔드 개발 효율성을 크게 향상하는 인사이트를 얻을 수 있을 것입니다.

#### Pixel Perfect를 위한 Figma 디자인 시스템 이해하기

프론트엔드 개발 과정 중 디자인을 코드로 변환하는 절차에서 ‘픽셀 퍼펙트’를 달성하는 것은 중요한 목표 중 하나입니다. 이를 위해, 먼저 Figma 디자인 시스템을 깊이 있게 이해하고, 이를 어떻게 효과적으로 CSS 코드로 변환할 수 있는지 탐색해 보겠습니다.

##### Figma Property to CSS Property

Figma에서 디자인을 구성할 때 사용하는 주요 요소들 중 하나는 노드의 기본 정보입니다. 예를 들어, 아래와 같이 프레임 정보에는 X, Y 위치, 너비(width), 높이(height), 회전(rotate), 테두리 둥근 정도(border radius) 및 내용물 잘림 여부(clip) 등이 있습니다.

```plain text
.Frame {
 /* Use Absolute Position */
 position: absolute;
  /* X */
 left: -8901px;


 /* Y */
 top: 2336px;


 /* W */
 width: 409px;


 /* H */
 height: 308px;


 /* Rotation */
 transform: rotate(90deg);


 /* Corner radius */
 border-radius: 0;


 /* Clip content */
 overflow:hidden;
}
```

이러한 요소들은 CSS 속성과 직접적으로 연결됩니다. 다행히도 Figma의 속성들과 CSS 속성들 사이에는 1대 1 대응 관계가 많습니다. 하지만 Figma에서 절댓값으로 표현된 포지셔닝 값(예: -8901px)은 CSS에서 직접 사용하기 어려운 경우가 있습니다. 예시로 음수인 -8901px의 값을 그대로 사용한다면 실제 화면에는 아무것도 보이지 않을 것입니다.

---

## 29. [OROR Forge: Figma to Code 도구 제작기 (2) 실전용으로 만들기 – tech.kakao.com](https://tech.kakao.com/2024/01/09/ororforge-2/)
> 생성: 2024-04-12

_(본문 없음)_

---

## 30. [내 장바구니](https://www.decathlon.co.kr/cart)
> 생성: 2024-10-18

### 내 장바구니

모두 선택

장바구니 비우기

9,900원

KIPRUN

러닝 터치스크린 장갑 웜 플러스 V2

색상

스모크 블랙

사이즈

M

수정삭제

19,900원

KALENJI

남성 러닝 반집업 긴팔 티셔츠 런 웜 100

색상

스모크 블랙

사이즈

L

수정삭제

24,900원

KALENJI

남성 러닝 레깅스 런 웜 100

색상

블랙

사이즈

L / W34

수정삭제

6,900원

KIPRUN

러닝 모자

색상

펄 그레이

사이즈

성인

수정삭제

39,900원

KIPRUN

웜 플러스 남성용 러닝 민소매 자켓

색상

블랙

사이즈

L

수정삭제

34,900원

KALENJI

남성용 방한 100 바지

색상

아스팔트 블루

사이즈

L / W34 L32

수정삭제

34,900원

KALENJI

남성용 웜 100 자켓

색상

아스팔트 블루

사이즈

L.

수정삭제

장바구니 요약

제품금액

171,300원

배송비

결제 시 계산됨

총 결제금액171,300원

쿠폰이 있으신가요?쿠폰 선택

결제하기계속 쇼핑하기

다른 고객이 구매한 상품

---

## 31. [3개월간 개발한 마이크로서비스에 498개의 테스트 코드를 작성한 시니어 개발자가 추천해준 <The Practical Test Pyramid>을 번역했다. 테스트의 종류와 이유, 철학을 Java, SpringBoot, JUnit을 사용한 예시와 함께 설명한다.

출처: 1nteger 🏄🏻‍♂️](https://search.app/LBnYd6sXzf8voKW79)
> 생성: 2024-10-28

테스트 피라미드 (이미지 출처: https://martinfowler.com/articles/microservice-testing/#conclusion-test-pyramid)

> 원글: The Practical Test Pyramid

#### 이 글을 번역하는 이유

최근에 이직한 미국 회사에 테스트에 진심인 시니어 개발자가 있었다. 그가 혼자서 약 3개월간 개발한 Java/Spring 기반의 마이크로서비스는 무려 498개의 테스트가 작성되었다.

물론 개수가 많다고 무조건 좋은 테스트는 아니지만, 그는 필요한 테스트들만 견고하게 작성했고, 다양한 종류와 범위의 테스트를 깔끔하게 구성하고 읽기 편하게 작성했으며, JUnit5와 Mockito 등의 테스트 라이브러리의 기능들을 풍부하게 활용해서 배울 점이 많았다.

심지어 테스트하기 쉬운 프로젝트도 아니었다:

1. 외부 서비스들 및 사내 마이크로서비스들간의 복잡한 연계가 필요한 서비스였고,

1. 1980년대부터 현재까지 운영중인 사내 레거시 시스템(BASIC과 COBOL로 개발됨)의 동작은 일정하지 않았으며,

1. 암호화되지 않은 개인정보들 때문에 DB 접근 권한이 제한되어 실시간 데이터를 얻을 수 없는 반면, 비즈니스 관리자들은 데이터를 직접 변경할 수 있었으며,

1. 다양한 이해관계자들에 의해 요구사항이 수없이 바뀌었고,

1. 시간 및 위치 데이터에 민감한 서비스라 미국 각 지역의 시차에 따라 다른 동작이 필요한 까다로운 서비스였다.

이정도로 복잡한 백엔드 서비스들은 봐왔지만 이렇게 확실하게 테스트하는 경우는 본 적이 없어서, 이래서 차는 독일차를 사라는건가..🤔라는 구시대적 선입견이 스멀스멀 피어오르기도 했다. (그는 독일 혹은 폴란드 출신이다)

그에게 너처럼 테스트 코드 작성하려면 어디서부터 시작해야해? 라고 물었는데, 그는 곧바로 Test Pyramid를 먼저 이해하는게 좋아라며 이 글과 Testing Strategies in a MicroService를 추천해줬다. 그래서 읽는 김에 번역! 🙃

> 모든 이미지의 출처는 원글입니다. (

📌 목차

1. 테스트 자동화의 중요성

1. 테스트 피라미드

1. 샘플 어플리케이션

1. 단위 테스트 (Unit Test)

1. 통합 테스트 (Integration Test)

1. 계약 테스트 (Contract Test)

1. UI 테스트

1. End-to-End 테스트

1. 인수 테스트 (Acceptance Test)

1. 탐색 테스트 (Exploratory Testing)

1. 테스트 용어에 대한 혼란

1. 배포 파이프라인에 테스트 넣기

1. 테스트 중복 피하기

1. 깔끔한 테스트 코드 작성

1. 결론

소프트웨어는 배포 전에 테스트가 필요합니다. 소프트웨어 개발이 발전함에 따라 소프트웨어 테스트 방식도 발전했습니다. 개발팀은 수많은 소프트웨어 테스터를 보유하는 대신 테스트를 자동화하는 방향으로 발전했습니다. 테스트를 자동화하면 며칠, 몇 주가 아니라 단 몇 초, 몇 분 만에 소프트웨어의 고장 여부를 알 수 있습니다.

이 글에서는 마이크로서비스 아키텍처, 모바일 앱, IoT 에코시스템 등 구축 대상에 관계없이 응답성, 안정성, 유지보수성을 갖춘 균형 잡힌 테스트 포트폴리오가 어떤 모습이어야 하는지 살펴봅니다. 또한 효과적이고 가독성 높은 자동화된 테스트를 구축하는 방법에 대해서도 자세히 살펴볼 것입니다.

#### 테스트 자동화의 중요성

소프트웨어는 우리가 살고 있는 세상의 필수적인 부분이 되었습니다. 소프트웨어는 비즈니스의 효율성을 높인다는 초기의 목적을 넘어섰고, 혁신의 수레바퀴는 점점 더 빠르게 돌아가고 있습니다.

이에 발 맞추려면 품질 저하 없이 소프트웨어를 더 빠르게 제공할 수 있는 방법을 모색해야 합니다. 소프트웨어가 언제든지 배포될 수 있도록 자동으로 보장하는 지속적 배포를 사용하면, 빌드 파이프라인을 사용하여 소프트웨어를 자동으로 테스트하고 프로덕션 환경에 배포할 수 있습니다.

수동적이고 반복적인 작업에 시간을 허비하고 싶지 않다면 빌드부터 테스트, 배포 및 인프라에 이르기까지 모든 것을 자동화하는 것이 유일한 방법입니다.

Figure 1: Use build pipelines to automatically and reliably get your software into production

기존 소프트웨어 테스트는 어플리케이션을 테스트 환경에 배포한 다음 사용자 인터페이스를 클릭해 문제가 있는지 확인하는 등의 수작업으로 이루어졌습니다. 이러한 테스트는 보통 테스터가 일관된 검사를 수행할 수 있도록 테스트 스크립트에 의해 지정됩니다.

모든 변경 사항을 수동으로 테스트하는 것은 시간이 많이 걸리고 반복적이며 지루합니다. 반복은 지루하고 지루함은 실수로 이어지며 주말이 되면 다른 일을 찾게 됩니다.

다행히도 반복적인 작업에 대한 해결책이 있습니다: 자동화

반복적인 테스트를 자동화하면 더 이상 소프트웨어가 제대로 작동하는지 확인하기 위해 무의식적으로 테스트 절차를 따를 필요가 없습니다. 테스트를 자동화하면 눈 하나 깜짝하지 않고 코드베이스를 변경할 수 있습니다. 적절한 테스트 도구 없이 대규모 리팩토링을 시도해 본 적이 있다면 이것이 얼마나 무서운 경험인지 잘 알고 계실 것입니다.

도중에 실수로 무언가를 망가뜨렸는지 어떻게 알 수 있을까요? 모든 수동 테스트 케이스를 살펴보는 것이 바로 그 방법입니다. 하지만 솔직히 말씀드리자면 이 과정이 정말 즐겁나요? 커피를 한 모금 마시면서 큰 규모의 변경 사항을 적용하고 몇 초 안에 문제 여부를 알 수 있다면 어떨까요?

#### 테스트 피라미드

자동화된 테스트를 위해서는 테스트 피라미드라는 핵심 개념을 알아야 합니다. Mike Cohn은 그의 저서 Succeeding with Agile에서 이 개념을 고안했습니다. 테스트 피라미드는 다양한 테스트 계층에 대해 생각하도록 돕는 훌륭한 시각적 은유입니다. 또한 각 계층에서 얼마나 많은 테스트를 수행해야 하는지도 알려줍니다.

Figure 2: The Test Pyramid

Mike Cohn의 테스트 피라미드는 세 가지 계층으로 구성되어 있습니다:

1. 단위 테스트

1. 서비스 테스트

1. 사용자 인터페이스 테스트

안타깝게도 테스트 피라미드의 개념은 자세히 살펴보면 약간 부족합니다. Mike Cohn의 테스트 피라미드의 이름이나 일부 개념적 측면이 이상적이지 않다고 주장하는 사람들도 있는데, 저도 동의합니다. 현대적인 관점에서 보면 이 테스트 피라미드는 지나치게 단순해 보이므로 오해의 소지가 있을 수 있습니다.

그럼에도 불구하고 테스트 피라미드의 본질은 단순하기 때문에 테스트를 구축할 때 도움이 됩니다. 가장 좋은 방법은 Cohn의 원래 테스트 피라미드에서 두 가지를 기억하는 것입니다:

1. 다양한 테스트 작성

1. 상위 계층으로 갈수록 더 적은 테스트 작성

작고 빠른 단위 테스트를 많이 작성하세요. 애플리케이션을 처음부터 끝까지 테스트하는 높은 수준의 테스트는 거의 작성하지 말고 좀 더 세분화된 테스트를 작성하세요. 유지 관리가 어렵고 실행하는 데 너무 오래 걸리는 테스트를 작성하지 않도록 주의하세요.

Cohn의 테스트 피라미드에서 각 계층의 이름에 너무 집착하지 마세요. 사실 서비스 테스트는 이해하기 어려운 용어입니다(많은 개발자가 이 계층을 완전히 무시하는 경우가 많다고 Cohn 자신도 이야기합니다). react, angular, ember.js 등과 같은 단일 페이지 애플리케이션 프레임워크의 시대에는 UI 테스트가 피라미드의 최상위 레벨에 있을 필요가 없으며 이러한 모든 프레임워크에서 UI를 완벽하게 단위 테스트할 수 있다는 것이 분명해졌습니다.

원래 이름의 단점을 고려할 때, 코드베이스와 팀의 논의에서 일관성을 유지한다면 테스트 계층에 다른 이름을 붙이는 것도 괜찮습니다.

#### 샘플 어플리케이션

저는 테스트 피라미드의 여러 계층에 대한 테스트가 포함된 Spring-Testing 저장소를 만들었습니다. 👇

이 샘플 애플리케이션은 일반적인 마이크로서비스의 특징을 보여줍니다. 이 애플리케이션은 REST 인터페이스를 제공하고 데이터베이스와 통신하며 타사 REST 서비스에서 정보를 가져옵니다. 이 애플리케이션은 Spring Boot로 구현되어 있으며 이전에 Spring Boot로 작업한 적이 없더라도 이해할 수 있습니다.

Github에서 코드를 확인하세요. README에는 어플리케이션을 실행하는 데 필요한 지침과 자동화된 테스트가 포함되어 있습니다.

##### 기능

이 어플리케이션의 기능은 간단합니다. 세 개의 엔드포인트가 있는 REST 인터페이스를 제공합니다:

- GET /hello 👉 “Hello World”를 반환합니다. 항상.

- GET /hello/{성} 👉 제공된 성을 가진 사람을 조회합니다. 알려진 사람인 경우 “안녕하세요 {이름} {성}”을 반환합니다.

- GET /weather 👉 독일 함부르크의 현재 날씨 상태를 반환합니다.

##### 시스템 구조

시스템은 다음과 같은 구조를 가지고 있습니다:

Figure 3: the high level structure of our microservice system

이 마이크로서비스는 HTTP를 통해 호출할 수 있는 REST 인터페이스를 제공합니다. 일부 엔드포인트의 경우 데이터베이스에서 정보를 가져옵니다. 그 외에 HTTP를 통해 외부 날씨 API를 호출하여 현재 날씨 상태를 가져와 표시합니다.

##### 내부 아키텍처

내부적으로 Spring의 전형적인 아키텍처를 가지고 있습니다:

Figure 4: the internal structure of our microservice

- Controller 클래스는 REST 엔드포인트를 제공하고 HTTP 요청 및 응답을 처리합니다.

- Repository 클래스는 데이터베이스와 인터페이스하고 퍼시스턴트 스토리지에 데이터를 쓰고 읽는 작업을 처리합니다.

- Client 클래스는 다른 API와 통신하며, 저희의 경우 darksky.net 날씨 API에서 HTTPS를 통해 JSON을 가져옵니다.

- Domain 클래스는 도메인 로직을 포함한 도메인 모델을 캡처합니다(이 어플리케이션에서는 아주 사소한 부분입니다).

경험이 많은 Spring 개발자는 자주 사용하는 레이어가 누락된 것을 발견할 수 있습니다: Domain-Driven Design(도메인 중심 설계)에서 영감을 받아 많은 개발자들이 서비스 클래스로 구성된 서비스 레이어를 구축합니다. 저는 이 애플리케이션에 서비스 레이어를 포함하지 않기로 결정했습니다.

한 가지 이유는 애플리케이션이 충분히 단순하기 때문에 서비스 계층은 불필요했습니다. 다른 하나는 사람들이 서비스 계층을 지나치게 많이 사용한다고 생각하기 때문입니다. 저는 종종 전체 비즈니스 로직이 서비스 클래스 내에 캡처된 코드베이스를 접하곤 합니다. 도메인 모델은 동작을 위한 것이 아니라 데이터를 위한 계층이 될 뿐입니다(Anemic Domain Model). 일반적인 애플리케이션에서 이러한 방식은 코드를 잘 구조화하고 테스트할 수 있는 잠재력을 낭비하고 객체 지향의 힘을 충분히 활용하지 못합니다.

저희 repository는 간단하고 간단한 CRUD 기능을 제공합니다. 코드를 단순하게 유지하기 위해 Spring Data를 사용했습니다. Spring Data는 직접 롤링하는 대신 사용할 수 있는 간단하고 일반적인 CRUD repository 구현을 제공합니다. 또한 프로덕션에서와 같이 실제 PostgreSQL 데이터베이스를 사용하는 대신 테스트를 위해 인메모리 데이터베이스를 띄워주는 작업도 처리해 줍니다.

코드베이스를 살펴보고 내부 구조에 익숙해지도록 하세요. 다음 단계에 유용할 것입니다: 어플리케이션 테스트!

#### 단위 테스트 (Unit Test)

테스트의 기초는 단위 테스트로 구성됩니다. 단위 테스트는 코드베이스의 특정 단위(테스트 대상)가 의도한 대로 작동하는지 확인합니다. 단위 테스트는 모든 테스트 중 범위가 가장 좁습니다. 단위 테스트는 다른 유형의 테스트보다 훨씬 더 많을 것입니다.

Figure 5: A unit test typically replaces external collaborators with test doubles

##### 단위(Unit)란 무엇인가?

세 사람에게 단위 테스트의 맥락에서 '단위'가 무엇을 의미하는지 물어본다면 아마도 약간 미묘한 차이가 있는 네 가지 대답을 들을 수 있을 것입니다. 어느 정도는 각자의 정의에 따른 문제이며 정답이 없어도 괜찮습니다.

함수형 언어로 작업하는 경우 단위는 단일 함수가 될 가능성이 높습니다. 단위 테스트는 다양한 매개 변수를 사용하여 함수를 호출하고 예상되는 값을 반환하는지 확인합니다. 객체 지향 언어에서 단위는 단일 메서드부터 전체 클래스까지 다양할 수 있습니다.

##### 사교적이거나 고독한 (Sociable and Solitary)

> 이 부분과 관련해서는 Martin Fowler의

어떤 사람들은 완벽한 격리와 복잡한 테스트 설정을 피하기 위해 테스트 대상 주제의 모든 공동 작업자(예: 테스트 대상 클래스에서 호출하는 다른 클래스)를 Mock 또는 Stub으로 대체해야 한다고 주장합니다. 반면, 어떤 사람들은 속도가 느리거나 부작용이 더 큰 공동 작업자(예: 데이터베이스에 접근하거나 네트워크 호출을 하는 클래스)만 Stub이나 Mock 테스트를 해야 한다고 주장합니다.

사람들은 모든 공동 작업자를 Stub하는 테스트는 고독한 단위 테스트, 실제 공동 작업자와 대화할 수 있는 테스트는 사교적인 단위 테스트라고 부릅니다(Jay Fields의 Working Effectively with Unit Tests 에서 이러한 용어가 만들어졌습니다). 시간이 여유가 있다면 다른 학파의 장단점(Martin Fowler의 Mocks Aren't Stubs)에 대해 자세히 읽어볼 수 있습니다.

---

## 32. [🙉FixtureMonkey로 TestFixture를 만들고 테스트 코드 작성하기

출처: TestFixture를 쉽게 생성해 주는 라이브러리가 있다? | 올리브영 테크블로그](https://search.app/9TJn9aQ9UCeqWvFm7)
> 생성: 2024-10-28

안녕하세요. 😀

올리브영에서 백엔드 개발을 하고 있는 윤노트입니다.

테스트 코드를 작성할때 사용하는 Fixture에 대한 설명과 사용하면서 발생한 이슈들 그리고 FixtureMonkey로 이를 해결한 방법을 소개합니다.

#### 🛠️ Fixture

Fixture를 단어 그대로 해석하면 고정되어 있는 물체를 의미합니다.

개발에서 Fixture 란 다음과 같습니다.

#### 🤔 Fixture 어떻게 사용하고 있는데?

테스트 코드를 작성하는 개발자라면 한.번.쯤은 "어떻게 테스트용 객체를 구성해야 할지?" "어떻게 데이터를 구성해야 재사용 하기 좋은 객체를 생성할지" 고민해 보셨을 거라고 생각합니다.

이런 고민을 해결하기 위해서는 보통 아래와 같은 방식을 활용할 수 있습니다.

- 생성자를 통해 생성하는 방식

- 패턴을 활용하는 방식

- JSON 파일로 만들어놓고 ObjectMapper를 통해 불러오는 방식

여러 가지 방식중 파트너오피스 스쿼드 에서는 Test Data Builder 패턴과 Object Mother 패턴 등의 패턴을 활용하는 방식과, JSON 파일을 Object로 변환하는 방식을 활용하여 테스트 코드를 작성했습니다.

#### 🛠️ 직접 생성자로 Fixture 생성하기

```plain text

public class SampleTest {

    private static User user;

    @BeforeAll
    static void setup() {
        user = new User(/* name */ "윤노트",  /* age */ 32,  /* intro */"🧑‍💻");
    }

    @Test
    void sampleTest() {

        final String expectName = "윤노트";
        final int age = 32;
        final String intro = "🧑‍💻";
        final User actual = UserFixture.createUser();

        assertThat(actual.getName()).isEqualTo(expectName);
        assertThat(actual.getAge()).isEqualTo(age);
        assertThat(actual.getIntro()).isEqualTo(intro);
    }
}
```

#### 🛠️ Test Data Builder 패턴과 Object Mother 패턴으로 Fixture 생성하기

아래와 같이 구현하면 필요한 부분에 대해 편의 메서드로 직접 생성하여 사용할 수 있습니다.

##### @Builder를 사용한 User 코드

```plain text
/** User.class */
@Getter
@Builder
public class User {

    private String name;
    private int age;
    private String intro;

    private User (UserBuilder userBuilder) {
        this.name = userBuilder.name;
        this.age = userBuilder.age;
        this.intro = userBuilder.intro;
    }
}

```

##### 직접 구현한 Builder를 사용하는 User 코드

```plain text
/** User.class */
@Getter
public class User {

    // 필드 생략
    //...

    private User (UserBuilder userBuilder) {
        //...
    }

    public static class UserBuilder {

        // 필드 생략
        //...

        // 메서드 생략
        // ...

        public User build() {
            return new User(this);
        }
    }
}

```

##### UserFixture 코드

```plain text
public class UserFixture {
    public static User createUser() {
        // 직접 작성한 Builder
        return new User.UserBuilder()
                .name("윤노트")
                .age(32)
                .intro("🧑‍💻")
                .build();
    }

    public static User createUserBuilderType() {
        // Lombok을 사용한 Builder
        return User.builder()
                .name("윤노트")
                .age(32)
                .intro("🧑‍💻")
                .build();
    }
}
```

##### 테스트 코드

#### 🤔 기존 방식에서 발생할 수 있는 문제

위처럼 Fixture를 사용하여 테스트 코드를 작성할 때 발생할 수 있는 문제들이 있습니다.

1.  

1.  

1.  

(조너선 폴 아이브의 유명한 격언에 sudo rm -rf 를 얹어보았습니다.)

파트너오피스 스쿼드에서는 이런 문제들을 해결하기 위해 Fixture Monkey를 도입했습니다.

#### 기존 Fixture를 바꿔보자! 🙉 Fixture Monkey 등장!

FixtureMonkey 대문

(이미지 출처 :  Fixture Monkey 공식 사이트)

#### ✍️ 편한 건 알았으니 이제 사용해보자!

사용법은 간단합니다. 사용하고자 하는 코드에 FixtureMonkey.create()를 사용하여 쉽게 할 수 있습니다.

##### 위 사진은 실제 코드를 디버깅 모드로 실행하였을 때 데이터 결과값입니다.

##### users 변수를 확인해 보면 랜덤하게 생성된 size 5의 컬렉션을 반환한 것을 확인할 수 있습니다.

##### 또한 각각 index에 해당하는 row에 Fixture Monkey가 랜덤한 값들을 넣어준 것을 확인할 수 있습니다.

해당 코드는 Builder를 통해 생성되는 특정 Field의 데이터 값을 고정하거나, Fixture Monkey에서 제공하는 Arbitraries를 사용하여 특정 범위의 값만 넣도록 설정한 예입니다. age의 경우 10~100사이의 값만 허용한다는 내용입니다.

우측 사진처럼 각 index의 데이터의 age가 10 이상 100 이하인 것을 확인할 수 있습니다.

🔥 직접 테스트하기 위해 User.class를 생성하여 돌렸더니 실행이 안 되거나 데이터가 만들어지지 않는다면 Getter, Setter를 추가해 주시기를 바랍니다! 해당 내용은 아래에서 한 번 더 다루겠습니다.

#### ❓ 파트너오피스 스쿼드에서는 어떻게 적용하였을까?

#### 데이터 기본 생성 전략 변경

Fixture Monkey 인스턴스 생성 방법 Fixture Monkey의 기본 생성 방식은 BeanArbitraryIntrospector 입니다.

##### ⭐ BeanArbitraryIntrospector

BeanArbitraryIntrospector 방식은 리플렉션과 Setter 메서드를 사용하여 객체를 생성하기 때문에 생성하고자 하는 클래스에 기본 생성자와 Setter가 있어야 합니다.

##### ⭐ ConstructorPropertiesArbitraryIntrospector

ConstructorPropertiesArbitraryIntrospector 방식은 이름 그대로 생성자를 이용한 생성 방식입니다.

##### ⭐ FieldReflectionArbitraryIntrospector

FieldReflectionArbitraryIntrospector는 리플렉션 방식을 이용하여 인스턴스를 생성하고 필드에 값을 설정합니다.

따라서 기본 생성자와 Getter 또는 Setter가 있어야 한다고 설명이 되어있지만, 실제 테스트시 Getter, Setter 없이 기본 생성자만 있어도 생성됩니다.

단, final이 아닌 가변 객체에 대해서는 @Getter, @Setter가 없는 경우도 생성된다고 합니다!

https://github.com/naver/fixture-monkey/issues/961#issuecomment-2021906200

##### ⭐ BuilderArbitraryIntrospector

BuilderArbitraryIntrospector는 빌더 방식을 이용하여 인스턴스를 생성하고 필드에 값을 설정합니다.

Lombok @Builder로 사용할 수 있으며, Lombok을 사용하지 않는 경우 builder, build 이름을 갖는 메서드를 생성해 주면 정상적으로 데이터가 설정되어 객체가 생성되는 것을 확인할 수 있습니다.

##### ⭐ FailoverArbitraryIntrospector

테스트 코드를 작성하다 보면 작성된 코드의 객체 생성 방식이 모두 달라 단일로는 생성되지 않는 경우가 발생할 수 있습니다. 그런 경우 FailoverArbitraryIntrospector를 사용하여 여러 개의 생성 방식을 지정할 수 있습니다.

#### 기존 Fixture 생성 방식을 Fixture Monkey로 변경

기존 파트너오피스 스쿼드에 작성된 테스트 코드는 test/resources 하위에 도메인별 fixture에 해당하는 JSON 파일들을 구성하고 파일을 읽어 ObjectMapper를 통해 객체로 변환하여 사용하였습니다.

하지만 JSON 파일의 경우 변환하고자 하는 클래스에 필드가 없지만 JSON 파일안에 해당 키가 있다면 변환 시 ObjectMapper에서 UnrecognizedPropertyException을 발생시켜 JSON 파일의 구조가 변경되면 해당 구조를 반영하기 위해 모델 클래스를 업데이트해야 합니다.

위 예제처럼 Fixture Monkey를 사용하면 몇 줄의 코드로 Fixture의 생성, 정상 케이스, 엣지 케이스에 대해서 쉽게 생성 및 재사용 가능합니다.

#### ♻️ Utils 클래스 변경 및 재사용성 구성

첫 번째는 Common(Util) 클래스로 변경하는 내용입니다. Request, Response, Domain, Entity 처럼 용도에 따라 객체를 생성하는 방식이 다르기 때문에 FixtureMonkey객체를 용도에 따라 분리하는것이 아닌 FailoverIntrospector을 사용하여 구성하도록 변경하였습니다.

두번째는 재사용 가능한 객체들에 대한 정의 입니다. 해당 예제는 실제 코드가 아닌 샘플 코드입니다.

이름은 윤노트인데 나이만 32살, 33살로 구성하여 테스트 코드를 작성과 같은 간단한 예를 들겠습니다.

(설명을 위해 간단한 예를 들었습니다.)

위와 같이 ArbitraryBuilder를 사용하여 구성하는 부분을 재사용하여 특정 필드들만 set하여 사용할 수 있습니다.

#### 💭 정리

테스트 코드를 작성하는 분들이라면 🙉FixtureMonkey를 사용하는 것을 추천합니다.

테스트 코드를 작성하는 것이 매우 중요하다는 것을 모두 알고 있지만, 업무를 보다 보면 시간이 부족하거나, 테스트 객체를 작성하는 것이 귀찮기 때문에 다음에 작성해야지!! 라고 넘어가는 분들도 많을 것으로 생각합니다.

Fixture Monkey는 대부분의 사람들이 쉽게 테스트 객체를 생성할 수 있도록 도와줍니다. 간단한 몇 줄의 코드로 다양한 테스트 케이스에 대해서 생성해 낼 수 있어 테스트 코드의 신뢰도가 올라갑니다. 그리고 코드의 양도 많지 않아서 더 깔끔하고 가독성 있는 객체를 생성할 수 있다는 큰 장점이 있습니다.

실제로 파트너오피스 스쿼드에서 약 500개 이상의 테스트 코드를 Fixture Monkey를 사용하여 작성했으며, 테스트에 필요한 관심 필드들을 명시적으로 표현하여 Fixture를 생성하는 시간을 줄일 수 있었고, 엣지 케이스들을 통해 미처 발견하지 못 한 케이스들에 대해서도 커버할 수 있었습니다.

긴 글 읽어주셔서 감사합니다.

##### 😝 Thanks to

- Fixture Monkey 도입을 위해 가이드 해주신 Architect. 코드다이버님 감사합니다.

- 함께 사용하며 가이드를 잡는데 도와준 팀, 스쿼드 개발자분들께 감사드립니다.

##### 참고

- https://github.com/naver/fixture-monkey

- https://naver.github.io/fixture-monkey/v1-0-0/

- https://velog.io/@pang_e/Fixture-Monkey%EB%9E%80

- https://jiwondev.tistory.com/272

---

## 33. [OpenAI의 새로운 Structured Outputs 기능으로 GPT API의  원하는 데이터 형식의 출력을 완벽하게 제어하세요. JSON 스키마 기반의 정확한 데이터 구조화로 AI 애플리케이션 개발의 새 지평을 엽니다.](https://search.app/DmoBcX9wZETHtxto8)
> 생성: 2025-01-07

인공지능과 자연어 처리 기술의 발전은 우리의 일상과 비즈니스 환경을 급속도로 변화시키고 있습니다. 그 중심에 서 있는 GPT모델은 이제 한 단계 더 진화했습니다. OpenAI가 최근 발표한 'Structured Outputs' 기능은 GPT API의 활용도를 획기적으로 높이는 혁신적인 도약입니다.

이 기능을 통해 개발자들은 원하는 데이터 형식을 100% 정확도로 얻을 수 있게 되었습니다. 이는 AI 기반 애플리케이션 개발에 있어 게임 체인저가 될 것입니다.

#### GPT API 구조화된 출력 (Structured Outputs) 이란 무엇인가?

Structured Outputs는 GPT 모델의 출력을 개발자가 지정한 JSON 스키마에 맞춰 생성하도록 하는 기능입니다. 이전까지 GPT 모델은 자유로운 텍스트 형태의 응답을 생성했지만, 이제는 정해진 구조에 맞는 데이터를 생성할 수 있게 된 것입니다.

GPT API 구조화된 출력 (Structured Outputs) 이란

##### 주요 특징:

1. JSON 스키마 기반: 개발자가 원하는 출력 형식을 JSON 스키마로 정의할 수 있습니다.

1. 100% 정확도: 모델은 지정된 스키마를 정확히 따르는 출력을 생성합니다.

1. 유연성: 복잡한 중첩 구조나 재귀적 데이터 구조도 지원합니다.

1. 안전성: 모델의 출력이 예측 가능해져 애플리케이션의 안정성이 향상됩니다.

#### GPT 구조화된 출력 (Structured Outputs)의 작동 원리

Structured Outputs는 크게 두 가지 방식으로 구현됩니다:

1. 함수 호출(Function Calling)을 통한 방식: 

함수 호출(Function Calling)을 통한 방식 - 입력 예시

함수 호출(Function Calling)을 통한 방식 - 출력 예시

1. 응답 형식(Response Format) 지정 방식: 

응답 형식(Response Format) 지정 방식 - 입력 예시

응답 형식(Response Format) 지정 방식 - 출력 예시

##### GPT 구조화된 출력 (Structured Outputs) 작동 방식 상세 설명

GPT 구조화된 출력 (Structured Outputs) 성능

이러한 방식을 통해 Structured Outputs는 100% 정확한 스키마 준수를 보장합니다.

#### Structured Outputs의 활용 사례

Structured Outputs는 다양한 분야에서 활용될 수 있습니다. 몇 가지 주요 사례를 살펴보겠습니다:

##### 1. 데이터 추출 및 정형화

비정형 데이터에서 구조화된 정보를 추출하는 작업이 훨씬 쉬워집니다. 예를 들어, 회의록에서 할 일 목록, 마감일, 담당자 정보를 자동으로 추출할 수 있습니다.

```plain text
{
  "action_items": [
    {
      "description": "프로젝트 계획서 작성",
      "due_date": "2024-08-15",
      "owner": "김철수"
    },
    {
      "description": "고객 미팅 준비",
      "due_date": "2024-08-10",
      "owner": "박영희"
    }
  ]
}

```

##### 2. 동적 UI 생성

사용자의 요구에 따라 동적으로 UI 구조를 생성할 수 있습니다. 이는 특히 대화형 AI 애플리케이션에서 유용합니다.

GPT API 구조화된 출력 - 동적 UI 생성 입력

GPT API 구조화된 출력 - 동적 UI 생성 입력

```plain text
{
  "type": "form",
  "label": "회원가입",
  "children": [
    {
      "type": "field",
      "label": "이름",
      "attributes": [
        { "name": "type", "value": "text" },
        { "name": "required", "value": "true" }
      ]
    },
    {
      "type": "field",
      "label": "이메일",
      "attributes": [
        { "name": "type", "value": "email" },
        { "name": "required", "value": "true" }
      ]
    },
    {
      "type": "button",
      "label": "가입하기",
      "attributes": [
        { "name": "type", "value": "submit" }
      ]
    }
  ]
}

```

##### 3. 복잡한 분석 결과 구조화

텍스트 분석, 감정 분석 등의 결과를 정형화된 형태로 얻을 수 있습니다.

GPT API 구조화된 출력 - 복잡한 분석 결과 구조화 입력 예시

GPT API 구조화된 출력 - 복잡한 분석 결과 구조화 출력 예시

아래는 감정 분석 결과 예시 입니다.

```plain text
{
  "sentiment_analysis": {
    "overall_sentiment": "positive",
    "confidence": 0.85,
    "aspects": [
      {
        "aspect": "제품 품질",
        "sentiment": "very positive",
        "confidence": 0.92
      },
      {
        "aspect": "고객 서비스",
        "sentiment": "neutral",
        "confidence": 0.78
      }
    ]
  }
}

```

#### Structured Outputs의 장점

#### Structured Outputs의 제한사항

#### Structured Outputs의 미래

Structured Outputs는 AI 모델과 실제 애플리케이션 간의 간극을 좁히는 중요한 발전입니다. 이 기능은 AI의 실용성과 신뢰성을 크게 높여, 더 많은 분야에서 AI 기술의 도입을 가속화할 것으로 예상됩니다.

향후 발전 방향:

1. 더 복잡한 스키마 지원: 현재의 제한사항들이 점차 해소될 것입니다.

1. 실시간 스키마 조정: 대화 맥락에 따라 동적으로 스키마를 변경하는 기능이 추가될 수 있습니다.

1. 멀티모달 지원 확대: 이미지, 음성 등 다양한 입력에 대해서도 구조화된 출력을 제공할 수 있을 것입니다.

#### 결론

OpenAI의 Structured Outputs는 GPT API의 활용 범위를 획기적으로 넓히는 혁신적인 기능입니다. 이를 통해 개발자들은 AI의 강력한 언어 이해 및 생성 능력을 더욱 정확하고 예측 가능한 방식으로 활용할 수 있게 되었습니다.

Structured Outputs는 단순히 기술적인 진보를 넘어, AI와 인간의 협업 방식을 한 단계 발전시키는 중요한 이정표가 될 것입니다. 이 기능을 통해 우리는 AI의 창의성과 인간의 구조화된 사고를 완벽하게 결합할 수 있게 되었습니다.

앞으로 Structured Outputs가 다양한 산업 분야에서 어떻게 활용되고, 어떤 혁신을 가져올지 주목해볼 필요가 있습니다. AI 기술의 발전 속도가 점점 더 빨라지고 있는 만큼, 이러한 새로운 기능들을 적극적으로 학습하고 활용하는 것이 미래 경쟁력 확보의 핵심이 될 것입니다.

보다 자세한 내용과 기술적 세부사항은 OpenAI의 Structured Outputs 공식 발표에서 확인할 수 있습니다. Structured Outputs의 등장으로 AI 개발의 새로운 장이 열렸습니다. 이제 우리에게 남은 과제는 이 강력한 도구를 어떻게 창의적으로 활용할 것인가 하는 것입니다.

---

## 34. [구글 개발자 계정 확인 기한 '조직' 계정 인증 | 스윙투앱 도움말](https://documentation.swing2app.co.kr/knowledgebase/playstore/organization)
> 생성: 2025-05-19

구글 개발자 계정 확인 기한이 도래하면, 개발자는 구글의 요청대로 계정 인증을 완료해야 합니다.

해당 도움말은 '조직' 개발자 계정에서 인증을 하는 방법입니다.

- 개인 개발자 계정 인증은 아래 가이드를 참고해주세요.

구글 개발자 계정 확인 기한 '개인' 계정 인증 | 스윙투앱 도움말

##### 해당 케이스는 계정을 등록하여 사용하고 있는 분들 중, 계정 확인 기한을 선택하여 기한이 시작된 경우만 해당됩니다.

2024년 3월 이후에 계정을 생성하신 분들은 이미 계정 인증을 완료하여 가입을 했기 때문에 해당 되지 않구요.

24년 이전 오래 전 계정을 등록하신 분들만 해당 됩니다.

#### 1.개발자 조직계정 인증

구글 플레이 콘솔 접속

Google Play Console | Google Play Console

[시작하기] 버튼 선택

개발자 계정 인증에 필요한 단계가 표시됩니다. [시작] 선택

계정 유형은 "조직 계정"을 선택해주세요. [다음] 선택

결제 프로필 만들기 또는 선택

- 기존에 계정에 만들어놓은 결제프로필이 있다면 선택하면 되구요.

없을 경우는 "새 결제 프로필 만들기"를 선택해서 프로필을 등록해주세요.

해당 매뉴얼에서는 결제프로필을 만들어서 등록하는 방법으로 알려드리겠습니다.

만들어놓은 DUNS 번호를 입력해주세요. [다음] 버튼 선택

추가정보: 주소와 우편번호 입력 후 [확인] 선택

- 조직 개발자 계정 이용을 위해서는 DUNS 번호를 만들어주셔야 합니다.

DUNS 번호 생성이 안되었다면 가이드를 보시고 만들어주세요

DUNS 넘버 발행 방법 | 스윙투앱 도움말

결제 프로필 생성이 완료되어, 계정에 추가되었다는 메시지가 뜹니다.

[확인]버튼 선택해주세요.

입력된 정보 확인 후 [다음]버튼 선택합니다

1)조직 규모: 네모칸 화살표를 선택해서 맞는 유형을 선택해주세요.

2)조직 전화번호: 회사 기본 연락처 기재해주세요. *국가번호 포함 입력 예)+821012345678

(꼭 회사 번호가 아니더라도 관리자 개인 핸드폰번호 입력도 가능해요)

3)조직 웹사이트: 회사에서 운영중인 웹사이트 URL을 입력해주세요.

사이트가 없으면 ‘웹사이트 없음’에 체크해주세요.

안내)

해당 정보는 개발자 프로그램 자격요건에 영향을 미치지 않습니다.

즉, 조직 규모가 작거나 웹사이트가 없더라도 개발자 계정을 만드는데는 아무 영향을 주지 않습니다.

구글에서 수집하는 세부정보일 뿐입니다.

1)개발자 전화번호 입력 *국가번호 포함 입력 예)+821012345678

- 기호, 국가코드, 지역번호 포함합니다.

입력한 번호로 인증번호가 전송됩니다. 인증까지 해야 번호 확인이 완료됩니다.

2)개발자 이메일주소 입력

- 입력한 메일로 인증번호가 전송됩니다. 인증까지 해야 번호 확인이 완료됩니다.

3)동의 체크

4)다음 버튼 선택

공개 개발자 프로필 검토

계정 인증을 할 경우 이제 개발자 정보가 플레이스토어 앱 정보에 노출이 됩니다.

개발자 이름, 이메일주소 등이 모두 노출되기 때문에 노출되는 담당자 정보를 확인 후 저장 버튼 선택해주세요.

개발자 정보 노출은 선택이 아닌 필수 입니다.

플레이스토어 어플) 개발자 소개 노출 화면 캡쳐

#### 2.본인 확인 인증

이어서 본인 확인 인증을 진행해주셔야 합니다.

- 본인 인증에는

- 휴대폰 본인 인증 (인증번호 전송)

- 조직 증명 서류(사업자등록증) 제출, 본인 인증을 위한 휴대전화 번호 제출, 주소 입력으로 정보를 제출합니다.

[시작하기] 버튼 선택시, 인증에 필요한 정보가 뜹니다.

[확인 절차 시작하기] 버튼을 선택합니다.

1)[업로드] 버튼을 선택해서 조직을 증명할 수 있는 서류를 제출합니다.

- 사업자등록증 , 상업 등기 초록, 사업 허가증, 과세 증명서 중에서 제출

2)다음 버튼 선택

본인(개인) 신원 정보 입력

3)이름 입력 *대표자로 입력하지 않아도 됩니다. 계정을 등록하는 본인(직원) 개인 정보로 입력해주세요.

4)주민번호 7자리 입력

5)이동 통신사 선택

6)연락처 :핸드폰 번호 입력

7)[다음] 선택

주소 입력 *회사 주소 등록

8)도/시 선택

9)시/군/구 선택

10)상세 주소 입력

11)우편번호 입력

12) [제출] 확인

13) 인증번호 6자리 코드 입력 후 [확인] 선택

14)확인 선택합니다.

#### 3.인증 완료

모든 정보 제출이 완료되었구요. 구글에서 제출된 정보를 검토 한 뒤 승인을 하게 됩니다.

보통 2일 내에 처리가 되는데 승인이 되면 바로 이용 가능하며, 서류가 적합하지 않을 경우 승인을 거절합니다.

받은 메일을 확인해서 조치사항 확인 후 다시 요청정보를 제출해야 합니다.

본인 인증 완료

주말이나 공휴일이 껴있으면 조금 더 지연될 수 있어요.

금요일에 신청하였고, 주말 지난 뒤 월요일 본인 인증이 완료되었다는 메일을 받았습니다.

본인 인증이 완료되면 이제 콘솔에서는 인증 관련 메시지가 사라지고 정책상 문제없이 계정 이용이 가능합니다

기한 내에 계정 인증을 하지 않으면 어떻게 되나요?

개발자 계정 및 계정에 등록된 앱이 모두 삭제됩니다.

---

## 35. [Spring boot thread pool / spring boot 쓰레드 풀 사용 / Multi Thread ThreadPoolTaskExecutor](http://trandent.com/article/spring/detail/776)
> 생성: 2025-08-14

_(본문 없음)_

---

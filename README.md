# React-at-Rest
A toolkit for building ridiculously fast web applications using React and RESTful APIs.

![Codeship Badge](https://codeship.com/projects/27ad5260-a389-0133-6b2c-3a486f5179bd/status?branch=master)

## Documentation

* [v2.0.0 Upgrade Guide](docs/updgrade.md)
* [Overview](docs/overview.md)
* [Store](docs/store.md)
* [DeliveryService](docs/deliveryservice.md)
* [RestForm](docs/restform.md)
* [App Events](docs/appevents.md)

## Sample Projects

Clone the react-at-rest examples repo to get started! https://github.com/PayloadDev/react-at-rest-examples

The examples project contains sample code in both [ES6](https://github.com/PayloadDev/react-at-rest-examples/tree/master/src/addressbook) and [CoffeeScript](https://github.com/PayloadDev/react-at-rest-examples/tree/master/src/blog).

## Main Concepts

* React-at-Rest is composed of 3 main classes, working in concert: `Store`, `DeliveryService`, and `RestForm`.
  * `Store`: manages all AJAX requests and holds the data returned by the server.
  * `DeliveryService`: React Component that manages and simplifies communication with the Stores.
  * `RestForm`: React Component for building forms and managing RESTful data flow.
* Uses Events for Store->Component communication.
* Written in CoffeeScript, **fully compatible with ES6**.
* Uses Bootstrap classes by default, but doesn't depend on Bootstrap.
* Uses subclasses instead of mixins or composition.
* Plays nicely with [react-router](https://github.com/rackt/react-router/)

## Requirements and Installation

React-at-Rest depends on `react`.

`npm install --save react-at-rest react`

## Battle Tested and Pragmatic

React-at-Rest is a collection of powerful tools that make writing SPAs faster and simpler. You'll be amazed at what you can accomplish in a very short period of time.

React-at-Rest powers the Payload SPA at payload.net.

# Getting Started

You can trivially consume a RESTful API using `Store` and `DeliveryService`

#### ES6
```es6
class BlogPosts extends DeliveryService {

  constructor(props) {
    super(props);
    // create a new Store which connected to an API at /posts
    this.postStore = new Store('posts');
  }

  // override bindResources to load all the resources needed for this component
  bindResources(props) {
    // retrieve all the posts from the Post Store
    this.retrieveAll(this.postStore);
  }

  render() {
    // show a loading message while loading data
    if !this.state.loaded
      return (<span>Loading...</span>)

    // iterate over all the blog posts loaded from our API
    let posts = this.state.posts.map((post) => {
      return (
        <div className="panel panel-default" key={post.id}>
          <div className="panel-heading">
            <h3 className="panel-title">{post.title}</h3>
          </div>
          <div className="panel-body">
            {post.body}
          </div>
        </div>
      )

    // render the posts
    return (
      <div>
        {posts}
      </div>
    )
  }   
}
```

#### CoffeeScript
```coffeescript
class BlogPosts extends DeliveryService

  constructor: (props) ->
    super props
    # create a new Store which connected to an API at /posts
    @postStore = new Store 'posts'


  # override bindResources to load all the resources needed for this component
  bindResources: (props) ->
    # retrieve all the posts from the Post Store
    @retrieveAll @postStore


  render: ->
    # show a loading message while loading data
    return <span>Loading...</span> unless @state.loaded

    # iterate over all the blog posts loaded from our API
    posts = for post in @state.posts
      <div className="panel panel-default" key={post.id}>
        <div className="panel-heading">
          <h3 className="panel-title">{post.title}</h3>
        </div>
        <div className="panel-body">
          {post.body}
        </div>
      </div>

    # render the posts
    <div>
      {posts}
    </div>
```

Or to load a single resource:

#### ES6
```es6
class BlogPost extends DeliveryService {

  constructor(props) {
    super(props);
    // create a new Store which connected to an API at /posts
    this.postStore = new Store('posts');
  }

  // override bindResources to load all the resources needed for this component
  bindResources(props) {
    // retrieve the post from the Post Store by id
    this.retrieveResource({this.postStore, id: this.props.postId});
  }

  render() {
    // show a loading message while loading data
    if !this.state.loaded
      return (<span>Loading...</span> )

    // render the post
    return (
      <div>
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">{this.state.post.title}</h3>
          </div>
          <div className="panel-body">
            {this.state.post.body}
          </div>
        </div>
      </div>
    )
  }
}
```

#### CoffeeScript
```coffeescript
class BlogPost extends DeliveryService

  constructor: (props) ->
    super props
    # create a new Store which connected to an API at /posts
    @postStore = new Store 'posts'


  # override bindResources to load all the resources needed for this component
  bindResources: (props) ->
    # retrieve the post from the Post Store by id
    @retrieveResource @postStore, id: @props.postId


  render: ->
    # show a loading message while loading data
    return <span>Loading...</span> unless @state.loaded

    # render the post
    <div>
      <div className="panel panel-default">
        <div className="panel-heading">
          <h3 className="panel-title">{@state.post.title}</h3>
        </div>
        <div className="panel-body">
          {@state.post.body}
        </div>
      </div>
    </div>
```

DeliveryService can load multiple resources in `bindResources`. Simply execute additional `subscribeAll`, `subscribeResource`, `retrieveAll` or `retrieveResource` methods.

## Creating and updating resources

`RestForm` takes care of rendering create/edit forms and submitting to the API.

#### ES6
```es6
class BlogPostForm extends RestForm {

  //build your form using Reactified versions of regular HTML form elements
  render() {
    return (
      <form onSubmit={this.handleSubmit} className="form-horizontal">
        <Forms.TextAreaInput {...this.getFieldProps('body')}
          labelClassName='col-sm-4'
          inputWrapperClassName='col-sm-8'/>
        <Forms.TextInput {...this.getFieldProps('author')}
          labelClassName='col-sm-4'
          inputWrapperClassName='col-sm-8'/>
        <div className='text-right'>
          <button className='btn btn-primary'>Create Post</button>
        </div>
      </form>
    )
  }
}
```

#### CoffeeScript
```coffeescript
class BlogPostForm extends RestForm

  # build your form using Reactified versions of regular HTML form elements
  render: ->
    <form onSubmit={@handleSubmit} className="form-horizontal">
      <Forms.TextAreaInput {...@getFieldProps('body')}
        labelClassName='col-sm-4'
        inputWrapperClassName='col-sm-8'/>
      <Forms.TextInput {...@getFieldProps('author')}
        labelClassName='col-sm-4'
        inputWrapperClassName='col-sm-8'/>
      <div className='text-right'>
        <button className='btn btn-primary'>Create Post</button>
      </div>
    </form>
```

Then render your form component with either a blank model, or one retrieved from the API

#### ES6
```es6
// in <BlogPosts /> component
<BlogPostForm model={{}} store={this.postStore} />

// or to edit a blog posted loaded in a DeliveryService subclass
<BlogPostForm model={this.state.post} store={this.postStore} />
```

#### CoffeeScript
```coffeescript
# in <BlogPosts /> component
<BlogPostForm model={{}} store={@postStore} />

# or to edit a blog posted loaded in a DeliveryService subclass
<BlogPostForm model={@state.post} store={@postStore} />
```

# Credits
React-at-Rest was developed by the team at [Payload](payload.net) and maintained by [Ben Sargent](https://github.com/fortybillion).

Event code from the [Backbone project](https://github.com/jashkenas/backbone).

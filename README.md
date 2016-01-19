# react-at-rest
An opinionated framework for building web applications using React and RESTful APIs.

## Sample Projects

Clone the react-at-rest examples repo to get started! https://github.com/PayloadDev/react-at-rest-examples

## Main Concepts

* ReactAtRest is composed of 3 main classes, working in concert: `Store`, `DeliveryService`, and `RestForm`. 
  * `Store`: manages all AJAX requests and holds the data returned by the server.
  * `DeliveryService`: React Component that manages and simplifies communication with the Stores.
  * `RestForm`: React Component for building forms and managing RESTful data flow.
* Uses Events for Store->Component communication.
* Written in CoffeeScript, fully compatible with ES6.
* Uses Bootstrap classes by default, but doesn't depend on Bootstrap.
* Uses subclasses instead of mixins or composition.
* Plays nicely with react-router

### Requirements and Installation

ReactAtRest depends on `react` and `lodash`

`npm install --save react-at-rest react lodash`

## Battle Tested and Pragmatic

ReactAtRest has no lofty goals of academic purity. It's a collection of powerful tools that make writing SPAs faster and simpler. You'll be amazed at what you can accomplish in a very short period of time. 

ReactAtRest powers the Payload SPA at payload.net.

# Getting Started

You can trivially consume a RESTful API using `Store` and `DeliveryService`
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

## Creating new resources

`RestForm` takes care of rendering create/edit forms and submitting to the API.

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
```coffeescript
# in <BlogPosts /> component
<BlogPostForm model={{}} store={@postStore} />

# or to edit a blog posted loaded in a DeliveryService subclass
<BlogPostForm model={@state.post} store={@postStore} />
```

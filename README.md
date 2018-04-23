# GDPR RAILS

### Rails Engine for GDPR compliance
![ioj](http://cdn-static.denofgeek.com/sites/denofgeek/files/styles/main_wide/public/6/85//bungle.jpg?itok=DPY-M9_6)
> Rainbow - Bungle's takes your privacy very seriously

## About this project

GDPR RAILS or PolicyManager was created with flexibility in mind to tackle the requirements of GDPR (General Data Protection Regulation) and it's currently being developed at preyproject and will be battle-tested on [preyproject.com](https://preyproject.com).

### Main Features:

#### Policy Rules
+ Configurable policy rules, supports activerecord validations for new or existing users
+ supports session-less terms to consent
+ versioning system for new policies
+ json endpoints to consume which terms must be consented

#### Portability
Portability module let's you define export options, this will generate a navegable static site with all the data
+ seamless data export with a configurable templates
+ downloads images to local filesystem
+ zip all the information
+ define export options


#### Forgotability
+ TBD

### Admin Panel
+ show 

## Installation
Add this line to your application's Gemfile: 

as `gem 'gdpr_rails'`

Then in yout application.rb require the policy_manager lib with 

`require "policy_manager"`


## Usage examples

in order to work with the engine you must supply some rules according to your needs, in order to be in compliance with GDPR you will need 3 rules at least. A cookie consent, an Privacy& TOS and a Age +16 confirmation. 
So, let's start doing that 

### Term rules

In your app router add the following:

```ruby
  mount PolicyManager::Engine => "/policies"
```

then add an initializer, `config/initializers/gdpr.rb` and inside it set your policy rules.

```ruby
config = PolicyManager::Config.setup do |c|
  c.add_rule({name: "cookie", sessionless: true }  )
  c.add_rule({name: "age", validates_on: [:create, :update], blocking: true })
  c.add_rule({name: "privacy_terms", validates_on: [:create, :update], blocking: true })
end

# if you are using devise, you must extend engines's controller with devise helpers in order to use current_user
PolicyManager::UserTermsController.send(:include, Devise::Controllers::Helpers)
```



### Policy rules:

+ **sessionless:** will allow rules to be available for non logged users, if accepted a cookie `cookies["policy_rule_cookie"]` will be generated.
+ **validates_on:** will require users validation, will automagically create virtual attributes for name, so if you set `age` you must supply in your forms a `policy_rule_age` checkbox in your form, if you don't supply those the user instance will validates and you will get the `policy_rule_age` in the activerecord errors response when try to save record.
+ **if:** you can add conditions as a Proc in order skip validations:
```ruby
  c.add_rule({name: "age", validates_on: [:create, :update], 
              if: ->(o){ o.enabled_for_validation } })
```

#### Policy handling:

There will be some endpoints that will return json or html to be handled on your frontend or directly in the engine web panel.
if the Engine was mounted on `/policies` then your routes will be:

    pending_user_terms GET    /user_terms/pending(.:format)                     policy_manager/user_terms#pending
    accept_multiples_user_terms PUT    /user_terms/accept_multiples(.:format)            policy_manager/user_terms#accept_multiples
    blocking_terms_user_terms GET    /user_terms/blocking_terms(.:format)              policy_manager/user_terms#blocking_terms
    accept_user_term PUT    /user_terms/:id/accept(.:format)                  policy_manager/user_terms#accept
    reject_user_term PUT    /user_terms/:id/reject(.:format)                  policy_manager/user_terms#reject
    user_terms GET    /user_terms(.:format)                             policy_manager/user_terms#index
    user_term GET    /user_terms/:id(.:format)                         policy_manager/user_terms#show



### Portability Rules

Export option & Portability rules will allow you to set up how and which data you will give to requester user.

#### Exporter:
+ **path**: where the folder will be generated
+ **resource**: which model
+ **index_template**: the first page. defaults to a simple ul li list of links tied to your rules
+ **layout**: a layout template to wrap the static site
+ **after_zip**: a callback to handle the zip file on the resource
+ **mail_helpers**: ,
+ **attachment_path**: Paperclip upload path , defaults to "portability/:id/build.zip",
+ **attachment_storage**: Paperclip storage, defaults to filesystem 
+ **expiration_link**: integer, defaults to 60 (1 minute),

#### Portability Rules:

portability rules  collection render. This will call a @user.articles
and will auto paginate records

```ruby
PolicyManager::Config.setup do |c|

  # minimal exporter setup
  c.exporter = { 
    path: Rails.root + "tmp/export", 
    resource: User 
  }

  # portability rules, collection render. This will call a @user.articles
  # and will auto paginate records
  c.add_portability_rule({
    name: "exportable_data", 
    collection: :articles, 
    template: "hello, a collection will be rendered here <%= @collection.to_json %>",
    per: 10
  })

  c.add_portability_rule({
    name: "my_account", 
    member: :account_data,
    template: "hellow , here a resource will be rendered <%= image_tag(@member[:image]) %> <%= @member.to_json %> "          
  })

end
```

If the content that will be delivered has images use the `image_tag` in your template. The remote image will be downloaded automatically and will be served locally in order to be in compliant with the Portability data.


### Web Endpoints and methods:




# TODO

+ anonimyzer
+ unsubscriber

#### Acknowlegments
+ Prey Team
+ Special thanks to our legal GDPR advisor: Paul Lagniel <paul@preyhq.com>

#### Main maintainers

+ Miguel Michelson - miguel@preyhq.com
+ Patricio Jofré - pato@preyhq.com

## Contributing
just fork the repo and send us a Pull Request, with some tests please :)

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

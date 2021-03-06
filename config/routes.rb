class Spree::PossibleBlog
  def self.matches?(request)
    return false if request.path =~ /(^\/+(admin|account|cart|checkout|content|login|pg\/|orders|products|s\/|session|signup|shipments|states|t\/|tax_categories|user)+)/
    !Spree::Blog.find_by_permalink(request.path).nil?
  end
end

class Spree::PossiblePage
  def self.matches?(request)
    return false if request.path =~ /(^\/+(admin|account|cart|checkout|content|login|pg\/|orders|products|s\/|session|signup|shipments|states|t\/|tax_categories|user)+)/
    !Spree::Page.active.find_by_path(request.path).nil?
  end
end

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :uploads

    resources :pages, :constraints => { :id => /.*/ } do
      collection do
        post :update_positions
      end

      resources :contents do
        collection do
          post :update_positions
        end
      end

      resources :images, :controller => "page_images" do
        collection do
          post :update_positions
        end
      end
    end

    resources :blogs, :constraints => { :id => /[a-z0-9\-\_\/]{3,}/ }

    resources :posts do
      resources :images,   :controller => "post_images" do
        collection do
          post :update_positions
        end
      end
      resources :products, :controller => "post_products"
      resources :categories, :controller => "post_categories"
    end

    resource :disqus_settings

  end

  constraints(Spree::PossiblePage) do
    get '*page_path', :to => 'pages#show', :as => :page
  end

  constraints(Spree::PossibleBlog) do
    constraints(
      :year  => /\d{4}/,
      :month => /\d{1,2}/,
      :day   => /\d{1,2}/
    ) do
      get ":blog_id/:year(/:month(/:day))" => "posts#index", :as => :post_date
      get ":blog_id/:year/:month/:day/:id" => "posts#show",  :as => :full_post
    end

    get ":blog_id/category/:id"   => "post_categories#show", :as => :post_category, :constraints => { :id => /.*/ }
    get ":blog_id/search/:query"  => "posts#search",         :as => :search_posts, :query => /.*/
    get ":blog_id/archive"        => "posts#archive",        :as => :archive_posts
    get ":blog_id"                => "posts#index",          :as => :blog_posts
  end
end

module ActiveCms
  class Page < ActiveRecord::Base
        
    self.table_name = 'active_cms_pages'
    
    extend FriendlyId
    friendly_id :make_slug, :use => :slugged
    
    #default_scope :order => :lft
    
    #has_ancestry
    acts_as_nested_set
    
    belongs_to :view_template
    
    #####
    ## Admin - Functions
    #####
    
    # nestedset functions
    # taken from http://stackoverflow.com/questions/2640553/how-to-reorder-nodes-within-a-node-using-awesome-nested-set
    # Shorthand method for finding the left sibling and moving to the left of it.
    def move_left
      move_to_left_of left_sibling if left_sibling
    end

    #Shorthand method for finding the right sibling and moving to the right of it.
    def move_right
      move_to_right_of right_sibling if right_sibling
    end

    # Move the node to the left of another node (you can pass id only)
    def move_to_left_of(node)
      move_to node, :left
    end

    # Move the node to the left of another node (you can pass id only)
    def move_to_right_of(node)
      move_to node, :right
    end
    
    # return header-title for show-page
    def show_title
      I18n.t('active_cms.pages.show.title', :title => self.title)
    end
    
    def skip_header
      return 'lal'
    end
    
    def skip_icon
      (self.skip)? 'S' : ''
    end
    def redirect_icon
      (self.redirect != "")? 'R' : ''
    end
    def menu_icon
      (self.menu)? 'M' : ''
    end
    
    def self.tree(ignore=nil)
      ancestry_options(ActiveCms::Page.scoped.arrange(:order => 'title'), ignore) { |i| 
        "#{'-' * i.depth} #{i.title}" if i.slug != ignore
      }
    end

    def self.ancestry_options(items, ignore)
      result = []
      items.map do |item, sub_items|
        result << [yield(item), item.id] unless item.slug == ignore
        result += ancestry_options(sub_items, ignore) { |i| 
          "#{'-' * i.depth} #{i.title}"  if i.slug != ignore
        }
      end
      result
    end
    
    #####
    ## Frontend - Functions
    #####
    
    def make_slug
      (!self[:slug] || self[:slug].nil? || self[:slug] == "")? title : self[:slug]
    end
    
    # return extern link to page
    def link
      self.redirect unless self.redirect.nil?
      ('/'+self.slug).gsub('//', '/')+'.shtml'
    end
 
  end
end

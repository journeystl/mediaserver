class Moviefile
  include Mongoid::Document
  include Mongoid::Paperclip
  has_attached_file :file, 
    :path           => '/home/ayl/moviefiles/'

  embedded_in :movie, :inverse_of => :moviefile
end

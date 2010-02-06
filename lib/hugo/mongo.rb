module Hugo; end

# Lauch Database Servers 
class Hugo::Mongo
  include Singleton
  include Hugo::Mixin::ParamsValidate

end
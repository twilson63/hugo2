require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo DNS" do
  it "should be valid" do
    zone = mock('Zerigo::DNS::Zone')
    zone.stub!(:id).and_return(1)
    Zerigo::DNS::Base.stub!(:user=)
    Zerigo::DNS::Base.stub!(:password=)
    Zerigo::DNS::Zone.stub!(:find_or_create).and_return(zone)
    Zerigo::DNS::Host.stub!(:update_or_create).and_return(mock('Zerigo::DNS::Host'))
  
    block = lambda do
      cloud "my_cloud" do 
        dns "www" do
          domain "example.com"
          user "name@email.com"
          token "1e23fjsda"
          type "A"
          ttl 86400
          data "123.123.123.123"
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
  end
end
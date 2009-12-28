Hugo do
  
  cloud "revcare" do
    
    database do |db|
      db.user ""
      db.pass ""
    end
    
    balancer do |lb|
      port 8080
      ssl_port 8443
    end
    
    2.times do
      instance "eirene4" do
        role :rails
        deploy true
        migrate true
      end
    end
  end
end

    
      
    
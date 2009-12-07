module AWS
  module EC2

    class Base < AWS::Base

      # Creates an AMI that uses an Amazon EBS root device from a "running" or "stopped" instance.
      #
      # AMIs that use an Amazon EBS root device boot faster than AMIs that use instance stores.
      # They can be up to 1 TiB in size, use storage that persists on instance failure, and can be
      # stopped and started.
      #
      # @option options [String] :instance_id ("") The ID of the instance.
      # @option options [String] :name ("") The name of the AMI that was provided during image creation. Constraints 3-128 alphanumeric characters, parenthesis (()), commas (,), slashes (/), dashes (-), or underscores(_)
      # @option options [optional,String] :description ("") The description of the AMI that was provided during image creation.
      # @option options [optional,Boolean] :no_reboot (false) By default this property is set to false, which means Amazon EC2 attempts to cleanly shut down the instance before image creation and reboots the instance afterwards. When set to true, Amazon EC2 does not shut down the instance before creating the image. When this option is used, file system integrity on the created image cannot be guaranteed.
      #
      def create_image( options = {} )
        options = { :instance_id => "", :name => "" }.merge(options)
        raise ArgumentError, "No :instance_id provided" if options.does_not_have? :instance_id
        raise ArgumentError, "No :name provided" if options.does_not_have? :name
        raise ArgumentError, "Invalid string length for :name provided" if options[:name] && options[:name].size < 3 || options[:name].size > 128
        raise ArgumentError, "Invalid string length for :description provided (too long)" if options[:description] && options[:description].size > 255
        raise ArgumentError, ":no_reboot option must be a Boolean" unless options[:no_reboot].nil? || [true, false].include?(options[:no_reboot])
        params = {}
        params["InstanceId"] = options[:instance_id].to_s
        params["Name"] = options[:name].to_s
        params["Description"] = options[:description].to_s
        params["NoReboot"] = options[:no_reboot].to_s
        return response_generator(:action => "CreateImage", :params => params)
      end


      # The DeregisterImage operation deregisters an AMI. Once deregistered, instances of the AMI may no
      # longer be launched.
      #
      # @option options [String] :image_id ("")
      #
      def deregister_image( options = {} )
        options = { :image_id => "" }.merge(options)
        raise ArgumentError, "No :image_id provided" if options[:image_id].nil? || options[:image_id].empty?
        params = { "ImageId" => options[:image_id] }
        return response_generator(:action => "DeregisterImage", :params => params)
      end


      # The RegisterImage operation registers an AMI with Amazon EC2. Images must be registered before
      # they can be launched.  Each AMI is associated with an unique ID which is provided by the EC2
      # service via the Registerimage operation. As part of the registration process, Amazon EC2 will
      # retrieve the specified image manifest from Amazon S3 and verify that the image is owned by the
      # user requesting image registration.  The image manifest is retrieved once and stored within the
      # Amazon EC2 network. Any modifications to an image in Amazon S3 invalidate this registration.
      # If you do have to make changes and upload a new image deregister the previous image and register
      # the new image.
      #
      # @option options [String] :image_location ("")
      #
      def register_image( options = {} )
        options = {:image_location => ""}.merge(options)
        raise ArgumentError, "No :image_location provided" if options[:image_location].nil? || options[:image_location].empty?
        params = { "ImageLocation" => options[:image_location] }
        return response_generator(:action => "RegisterImage", :params => params)
      end


      # The DescribeImages operation returns information about AMIs available for use by the user. This
      # includes both public AMIs (those available for any user to launch) and private AMIs (those owned by
      # the user making the request and those owned by other users that the user making the request has explicit
      # launch permissions for).
      #
      # The list of AMIs returned can be modified via optional lists of AMI IDs, owners or users with launch
      # permissions. If all three optional lists are empty all AMIs the user has launch permissions for are
      # returned. Launch permissions fall into three categories:
      #
      # Launch Permission Description
      #
      # public - The all group has launch permissions for the AMI. All users have launch permissions for these AMIs.
      # explicit - The owner of the AMIs has granted a specific user launch permissions for the AMI.
      # implicit - A user has implicit launch permissions for all AMIs he or she owns.
      #
      # If one or more of the lists are specified the result set is the intersection of AMIs matching the criteria of
      # the individual lists.
      #
      # Providing the list of AMI IDs requests information for those AMIs only. If no AMI IDs are provided,
      # information of all relevant AMIs will be returned. If an AMI is specified that does not exist a fault is
      # returned. If an AMI is specified that exists but the user making the request does not have launch
      # permissions for, then that AMI will not be included in the returned results.
      #
      # Providing the list of owners requests information for AMIs owned by the specified owners only. Only
      # AMIs the user has launch permissions for are returned. The items of the list may be account ids for
      # AMIs owned by users with those account ids, amazon for AMIs owned by Amazon or self for AMIs
      # owned by the user making the request.
      #
      # The executable list may be provided to request information for AMIs that only the specified users have
      # launch permissions for. The items of the list may be account ids for AMIs owned by the user making the
      # request that the users with the specified account ids have explicit launch permissions for, self for AMIs
      # the user making the request has explicit launch permissions for or all for public AMIs.
      #
      # Deregistered images will be included in the returned results for an unspecified interval subsequent to
      # deregistration.
      #
      # @option options [Array] :image_id ([])
      # @option options [Array] :owner_id ([])
      # @option options [Array] :executable_by ([])
      #
      def describe_images( options = {} )
        options = { :image_id => [], :owner_id => [], :executable_by => [] }.merge(options)
        params = pathlist( "ImageId", options[:image_id] )
        params.merge!(pathlist( "Owner", options[:owner_id] ))
        params.merge!(pathlist( "ExecutableBy", options[:executable_by] ))
        return response_generator(:action => "DescribeImages", :params => params)
      end


    end
  end
end


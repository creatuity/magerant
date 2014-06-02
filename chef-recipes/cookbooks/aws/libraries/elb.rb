require File.join(File.dirname(__FILE__), 'ec2')

module Opscode
  module Aws
    module Elb
      include Opscode::Aws::Ec2

      def elb
        @@elb ||= create_aws_interface(RightAws::ElbInterface)
      end
    end
  end
end

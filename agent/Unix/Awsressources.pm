# Plugin "Aws Ressources" OCSInventory
# Author: Léa DROGUET

package Ocsinventory::Agent::Modules::Awsressources;

use Encode qw(decode);
use POSIX qw(strftime);
use JSON::PP;


sub new {

    my $name="awsressources"; # Name of the module

    my (undef,$context) = @_;
    my $self = {};

    #Create a special logger for the module
    $self->{logger} = new Ocsinventory::Logger ({
        config => $context->{config}
    });
    $self->{logger}->{header}="[$name]";
    $self->{context}=$context;
    $self->{structure}= {
        name => $name,
        start_handler => undef,    #or undef if don't use this hook
        prolog_writer => undef,    #or undef if don't use this hook
        prolog_reader => undef,    #or undef if don't use this hook
        inventory_handler => $name."_inventory_handler",    #or undef if don't use this hook
        end_handler => undef       #or undef if don't use this hook
    };
    bless $self;
}

######### Hook methods ############
sub awsressources_inventory_handler {

    my $self = shift;
    my $logger = $self->{logger};
    my $common = $self->{context}->{common};


    $logger->debug("Yeah you are in awsressources_inventory_handler :)");

    # Please modify below variable if you chose any other profile name during aws cli configuration
    my $profileName = 'ocs';

    # Define here which regions you wish to scan for instances (the profile above must have access to these)
    my @regions = (
                'us-east-2',
                'us-east-1',
                );
    
    foreach my $region (@regions) {
        # Other query candidate that might be faster ... might be
        # aws ec2 --profile ocs describe-instances --query "Reservations[].Instances[].{InstanceId: InstanceId, ImageId: ImageId, Type: InstanceType, Key: KeyName, LaunchTime: LaunchTime, Monitoring: Monitoring.State, AvailabilityZone: Placement.AvailabilityZone, PrivateDns: PrivateDnsName, PrivateIP: PrivateIpAddress, Status: State.Name, StatusReason: StateTransitionReason, SubnetId: SubnetId, VpcId: VpcId, Architecture: Architecture, Networks: NetworkInterfaces,RootDeviceName: RootDeviceName, RootDeviceType: RootDeviceType, CpuCores: CpuOptions.CoreCount, CpuThreadsPerCore: CpuOptions.ThreadsPerCore}" --region us-east-2
        
        # Instances will be retrieved for every region specified above
        my $result = `aws ec2 --profile $profileName describe-instances --query "Reservations[].Instances[].{InstanceId: InstanceId, ImageId: ImageId, Type: InstanceType, Key: KeyName, LaunchTime: LaunchTime, Monitoring: Monitoring.State, AvailabilityZone: Placement.AvailabilityZone, PrivateDns: PrivateDnsName, PrivateIP: PrivateIpAddress, Status: State.Name, StatusReason: StateTransitionReason, SubnetId: SubnetId, VpcId: VpcId, Architecture: Architecture, Networks: NetworkInterfaces,RootDeviceName: RootDeviceName, RootDeviceType: RootDeviceType, CpuCores: CpuOptions.CoreCount, CpuThreadsPerCore: CpuOptions.ThreadsPerCore}" --region $region`;
        $result = decode_json $result;

        if (@{$result}) {
            $logger->debug("Generating xml data for region : $region");         
            print Dumper($result);             
            # instance level
            foreach my $instance (@{$result}) {
                push @{$common->{xmltags}->{AWS_INSTANCES}},
                {
                    RESERVATION_ID => "whatever",
                    OWNER_ID => "still whatever",
                    INSTANCE_ID => [$instance->{InstanceId}],
                    INSTANCE_TYPE => [$instance->{Type}],
                    LAUNCH_TIME => [$instance->{LaunchTime}],
                    AVAILABILTY_ZONE => [$instance->{AvailabilityZone}],
                    ARCHITECTURE => [$instance->{Architecture}],
                    KEY_NAME => [$instance->{Key}],
                    IMAGE_ID => [$instance->{ImageId}],
                    # AMI_LAUNCH_INDEX => [$instance->{AmiLaunchIndex}],
                    MONITORING => [$instance->{Monitoring}],
                    # STATE_CODE => [$instance->{State}{Code}],
                    STATE_NAME => [$instance->{Status}],
                    STATE_REASON => [$instance->{StatusReason}],
                    # VIRTUALIZATION_TYPE => [$instance->{VirtualizationType}],
                    # HIBERNATION_OPT_CONFIGURED => [JSON::PP::is_bool($instance->{HibernationOptions}->{Configured})],
                    # ENCLAVED_OPT_ENABLED => [JSON::PP::is_bool($instance->{EnclaveOptions}->{Enabled})],

                };

                push @{$common->{xmltags}->{AWS_INSTANCES_HARDWARE}},
                    {
                        RESERVATION_ID => "whatever",
                        OWNER_ID => "still whatever",
                        INSTANCE_ID => [$instance->{InstanceId}],
                        ROOT_DEVICE_NAME => [$instance->{RootDeviceName}],
                        ROOT_DEVICE_TYPE => [$instance->{RootDeviceType}],
                        CPU_CORE_COUNT => [$instance->{CpuCores}],
                        CPU_THREADS_PER_CORE => [$instance->{CpuThreadsPerCore}],
                    };

                foreach my $networkscat (@{$instance->{Networks}}) {
                    push @{$common->{xmltags}->{AWS_INSTANCES_NETWORKS}},
                    {
                        RESERVATION_ID => "whatever",
                        OWNER_ID => "still whatever",
                        INSTANCE_ID => [$instance->{InstanceId}],
                        MAC_ADDR => [$networkscat->{MacAddress}],
                        PRIVATE_DNS_NAME => [$instance->{PrivateDns}],
                        PRIVATE_IP_ADDR => [$instance->{PrivateIP}],
                        #PUBLIC_DNS_NAME => [$networkscat->{PublicDnsName}],
                        VPC_ID => [$instance->{VpcId}],
                        NETWORK_INTERFACE_ID => [$networkscat->{NetworkInterfaceId}],
                        SUBNET_ID => [$instance->{SubnetId}],

                    };

                }
                
            }
        } else {
            $logger->debug("No instances found for region : $region");
        }
    }




    $logger->debug("Finishing awsressources_inventory_handler ..");
}

1;

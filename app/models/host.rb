class Host < ActiveRecord::Base
  has_many :roles, :dependent => :destroy, :uniq => true
  has_many :stages, :through => :roles, :uniq => true # XXX uniq does not seem to work! You get all stages, even doubles
  
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_length_of :name, :maximum => 250
  
  attr_accessible :name, :memory
  
  before_validation :strip_whitespace
  
  def strip_whitespace
    self.name = self.name.strip rescue nil
  end
  
  def validate
    errors.add("name", "is not a valid hostname or IP") unless ( valid_ip? || valid_hostname? )
  end
  
  def valid_hostname?
    self.name == 'localhost' || self.name =~ /^([a-zA-Z0-9][a-zA-Z0-9._-]*\.)*[a-zA-Z0-9][a-zA-Z0-9._-]*\.[a-zA-Z]{2,5}$/
  end
  
  def valid_ip?
    if self.name =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
      ($1.to_i <= 255) && ($2.to_i <= 255) && ($3.to_i <= 255) && ($4.to_i <= 255)
    else
      false
    end
  end
  
  # returns true if there is enough memory on this host to deploy all assigned stages
  def sufficient_memory?
    return true if stages.blank?
    stages.uniq.map{|stage| stage.memory_need * stage.instances}.sum <= memory
  end
  
end

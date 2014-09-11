require 'spec_helper'

module Markety
  EMAIL = 'some@email.com'
  IDNUM    = 93480938
  
  

  describe Lead do
    it "should store the idnum" do
      lead_record = Lead.new(EMAIL, IDNUM)
      lead_record.idnum.should == IDNUM
    end

    it "should store the email" do
      Lead.new(EMAIL, IDNUM).email.should == EMAIL
    end

    it "should implement == sensibly" do
      lead_record1 = Lead.new(EMAIL, IDNUM)
      lead_record1.set_attribute('favourite color', 'red')
      lead_record1.set_attribute('age', '100')

      lead_record2 = Lead.new(EMAIL, IDNUM)
      lead_record2.set_attribute('favourite color', 'red')
      lead_record2.set_attribute('age', '100')

      lead_record1.should == lead_record2
    end

    it "should store when attributes are set" do
      lead_record = Lead.new(EMAIL, IDNUM)
      lead_record.set_attribute('favourite color', 'red')
      lead_record.get_attribute('favourite color').should == 'red'
    end

    it "should store when attributes are updated" do
      lead_record = Lead.new(EMAIL, IDNUM)
      lead_record.set_attribute('favourite color', 'red')
      lead_record.set_attribute('favourite color', 'green')
      lead_record.get_attribute('favourite color').should == 'green'
    end

    it "should yield all attributes through each_attribute_pair" do
      lead_record = Lead.new(EMAIL, IDNUM)
      lead_record.set_attribute('favourite color', 'red')
      lead_record.set_attribute('favourite color', 'green')
      lead_record.set_attribute('age', '99')

      pairs       = []
      lead_record.each_attribute_pair do |attribute_name, attribute_value|
        pairs << [attribute_name, attribute_value]
      end

      pairs.size.should == 3
      pairs.should include(['favourite color', 'green'])
      pairs.should include(['age', '99'])
      pairs.should include(['Email', EMAIL])
    end
    
    it 'should be instantiable from savon hash with no attributes' do
      savon_hash = {
        :id => IDNUM,
        :email => EMAIL,
        :foreign_sys_person_id => nil,
        :foreign_sys_type => nil,
        :lead_attribute_list => nil
      }
      
      actual = Lead.from_hash(savon_hash)
      expected = Lead.new(EMAIL, IDNUM)
      
      actual.should == expected
    end
    
    # When there is only one attribute, Marketo returns a Hash, not an Array
    it 'should be instantiable from savon hash with only one attribute' do
      savon_hash = {
        :id => IDNUM,
        :email => EMAIL,
        :foreign_sys_person_id => nil,
        :foreign_sys_type => nil,
        :lead_attribute_list => 
          {:attribute => { :attr_name => 'FirstName', :attr_value => 'Yaya', :attr_type => 'string'}}
      }
      
      actual = Lead.from_hash(savon_hash)
      
      expected = Lead.new(EMAIL, IDNUM)
      expected.set_attribute('FirstName', 'Yaya')
      
      actual.should == expected
    end
    
    it "should be instantiable from a savon hash" do
      savon_hash = {
          :email => EMAIL,
          :foreign_sys_type => nil,
          :lead_attribute_list => {
              :attribute => [
                { :attr_name => 'Company', :attr_type => 'string', :attr_value => 'Yaya'},
                { :attr_name => 'FirstName', :attr_type => 'string', :attr_value => 'James'},
                { :attr_name => 'LastName', :attr_type => 'string', :attr_value => 'O\'Brien'}
              ]
          },
          :foreign_sys_person_id => nil,
          :id => IDNUM
      }

      actual = Lead.from_hash(savon_hash)

      expected = Lead.new(EMAIL, IDNUM)
      expected.set_attribute('Company', 'Yaya')
      expected.set_attribute('FirstName', 'James')
      expected.set_attribute('LastName', 'O\'Brien')

      actual.should == expected
    end
  end
end

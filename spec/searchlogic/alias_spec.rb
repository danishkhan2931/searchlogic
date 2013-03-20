require 'spec_helper'

describe Searchlogic::Alias do 
  context ".convert_alias" do 
    it "converts an alias with an `all' condition" do 
      Searchlogic::Alias.convert_alias(:name_lte_all).should eq("name_less_than_or_equal_to_all")

    end
    it "converts an alias with an `any' condition" do 
      Searchlogic::Alias.convert_alias(:name_lte_any).should eq("name_less_than_or_equal_to_any")
    end

    it "returns a matchadata object if it finds an alias in the method" do 
      Searchlogic::Alias.convert_alias(:username_gte).should eq("username_greater_than_or_equal_to")
    end

    it "returns the method" do 
      Searchlogic::Alias.convert_alias(:username_greater_than_or_equal_to).should eq(:username_greater_than_or_equal_to)
    end

  end

describe "Searchlogic::ScopeReflectionExt::MatchAlias "do 
  before(:each) do 
    User.create(:name=>"James", :age => 26, :company_id => 34)
    @jon = User.create(:name=>"Jon", :email => "jon@James.com", :company_id => 4)
    @james = User.create(:name=>"aJJ", :username => "James", :company_id => 12)
    User.create(:name=>"Ben", :age => 28, :username => "JamesVanneman", :company_id => 15)
    @tren = User.create(:name=>"Tren", :age =>45)
  end


  describe "works with OR conditionals" do 
    it "with two of the same conditionals" do 
      users = User.name_eq_or_username_eq("James")
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "aJJ"])
    end
    it "when first conditional is omitted" do 
      users = User.name_or_username_eq("James")
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "aJJ"])

    end


    it "with two different conditionals" do 
      users = User.name_eq_or_email_contains("James")
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "Jon"])
    end
    it "with three different conditionals" do 
      users = User.name_eq_or_email_contains_or_username_bw("James")
      users.count.should eq(4)
      names = users.map(&:name)
      names.should eq(["James", "Jon","aJJ", "Ben"])
    end

    it "with multiple inequalities" do 
      users = User.age_or_company_id_gte(28)
      users.count.should eq(3)
      names = users.map(&:name)
      names.should eq(  ["James", "Ben", "Tren"])
    end
  end

  describe ".convert_alias" do
    it "matches ordering" do 
      Searchlogic::Alias.convert_alias(:ascend_by_id).should eq(:ascend_by_id)
    end 
       
    it "is == equals" do 
      users = User.name_is("James")
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "lt == less_than" do 
      users = User.age_lt(28)
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "before == less_than" do 
      users = User.age_before(28)
      users.count.should eq(1)
      names = users.map(&:name)
      names.should eq(["James"])
    end

    it "lte == less_than_or_equal_to" do 
      users = User.age_lte(28)
      users.count.should eq(2)
      names = users.map(&:name)
      names.should eq(["James", "Ben"])
    end
    it "gt and after == greater_than" do 
      gt_users = User.age_gt(28)
      after_users = User.age_after(28)
      gt_users.count.should eq(1)
      after_users.count.should eq(1)
      gt_users.first.name.should eq("Tren")
      after_users.first.name.should eq("Tren")
    end

    it "does_not_include == not_like" do 
      dni = User.name_does_not_include("e")
      dni.count.should eq(2)
      names = dni.map(&:name)
      names.should eq(["Jon", "aJJ"])
    end

    it " not_begin_with == does_not_begine_with" do 
      nbw = User.name_not_begin_with("J")
      nbw.count.should eq(3)
      names = nbw.map(&:name)
      names.should eq(["aJJ", "Ben", "Tren"])
    end

    it "ew = ends_with" do 
      ew = User.name_ew("en")
      ew.count.should eq(2)
      names = ew.map(&:name)
      names.should eq(["Ben", "Tren"])
    end
    it "not_end with == does_not_end_with" do 
      nendw = User.name_not_end_with("en")
      nendw.count.should eq(3)
      names = nendw.map(&:name)
      names.should eq(["James", "Jon", "aJJ"])
    end
    it "nil == null" do 
      nil_ages = User.age_nil
      nil_ages.count.should eq(2)
      names = nil_ages.map(&:name)
      names.should eq(["Jon", "aJJ"])
    end
    it "bw == beginswith" do
      begins_j = User.name_bw("J")
      begins_j.map(&:name).should eq(["James", "Jon"])
    end

    it "should have in" do 
      User.id_in(2,3).should eq([@jon, @james])
    end

    it "should have not in" do 
      User.id_not_in(2,3).should eq(User.all - [@jon, @james])
    end
  end
end  
end
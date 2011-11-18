require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class FakeUser
  include UserOauth
end

describe FakeUser do
  context "when i get the user data through oauth sn provider" do
    before(:each) do
      @user = create(:user, :uid => '1234')
      user_json =  '{"email":"forevertonny@gmail.com","id":5,"name":"Lorem Ipsum Dolor","nickname":"Dolor"}'
      subject.stubs(:_user).returns(@user)
      RestClient.stubs(:get).with(CUSTOM_PROVIDER_URL+"/users/1234").returns(user_json)
    end

    its(:sn_name) { should == "Lorem Ipsum Dolor" }
    its(:sn_nickname) { should == "Dolor" }
    its(:sn_email) { should == 'forevertonny@gmail.com' }
  end
end
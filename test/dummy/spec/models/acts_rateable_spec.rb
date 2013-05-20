require 'spec_helper'

describe ActsRateable do

  describe "associations" do
    
    let(:post) { FactoryGirl.create(:post) }
    let(:user) { FactoryGirl.create(:user) }
    
    before(:each){
      user.rate( post, rand(1..5) )
    }
    
    describe "resource" do
      it "should respond to rates" do
        post.should respond_to(:rates)
        post.rates.should_not be_empty
      end
      
      it "should respond to ratings" do
        post.should respond_to(:ratings)
        post.ratings.should_not be_nil
      end
    end
    
    describe "author" do
      it "should respond to rated" do
        user.should respond_to(:rated)
        user.rated.should_not be_empty
      end
    end
  end
  
  describe "scope" do
    
    let(:post) { FactoryGirl.create(:post) }
    
    before(:each){
      rand(1..20).times do
        FactoryGirl.create(:user).rate( post, rand(1..5) )
      end
    }
    
    it { Post.should respond_to(:order_by) }
    
    it "order_by should not be empty" do
      Post.order_by(:estimate).should_not be_empty
    end
  end
  
  describe "instance methods" do

    let(:post) { FactoryGirl.create(:post) }
    let(:user) { FactoryGirl.create(:user) }
    
    describe "rate" do
    
      it "should respond to rate" do
        post.should respond_to(:rate)
      end
    
      it "should create rate when rated" do
        expect{
          post.rate(user,4)
        }.to change { ActsRateable::Rate.count }
      end
    
      it "should create rating when rated" do
        expect{
          post.rate(user,4)
        }.to change { ActsRateable::Rating.count }
      end
      
      it "should not duplicate rate when re-rated" do
        post.rate(user,4)
        expect{
          post.rate(user,4)
        }.to_not change { ActsRateable::Rating.count }
      end
    end
    
    describe "rated_by" do
      it "should respond to rated_by" do
        post.should respond_to(:rated_by?)
      end
      
      it "should respond to rated_by" do
        post.rated_by?(user).should_not be_false
      end
    end
    
    describe "has_rated" do
      it "should respond to has_rated" do
        user.should respond_to(:has_rated?)
      end

      it "should respond to has_rated" do
        user.rated_by?(post).should_not be_false
      end
    end
  end
end
require 'spec_helper'

describe ActsRateable do
  describe 'associations' do
    let(:post) { FactoryGirl.create(:post) }
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      user.rate(post, rand(1..5))
    end

    describe 'resource' do
      it 'responds to rates' do
        expect(post).to respond_to(:rates)
        expect(post.rates).to_not be_empty
      end

      it 'responds to rating' do
        expect(post).to respond_to(:rating)
        expect(post.rating).to_not be_nil
      end
    end

    describe 'author' do
      it 'responds to rated' do
        expect(user).to respond_to(:rated)
        expect(user.rated).to_not be_empty
      end

      it 'responds to count' do
        expect(post).to respond_to(:count)
        expect(post.count).to_not be_nil
      end
    end
  end

  describe 'instance methods' do
    let(:post) { FactoryGirl.create(:post) }
    let(:user) { FactoryGirl.create(:user) }

    it 'responds to rate' do
      expect(post).to respond_to(:rate)
    end

    it 'should create rate when rated' do
      expect { post.rate(user, 4) }.to change { ActsRateable::Rate.count }
    end

    it 'should create rating when rated' do
      expect { post.rate(user, 4) }.to change { ActsRateable::Rating.count }
    end

    it 'should not duplicate rate when re-rated' do
      post.rate(user, 4)
      expect { post.rate(user, 4) }.to_not change { ActsRateable::Rating.count }
    end

    describe 'rated_by' do
      it 'responds to rated_by' do
        expect(post).to respond_to(:rated_by?)
      end

      it 'should not be rated_by(user)' do
        expect(post.rated_by?(user).empty?).to be(true)
      end

      it 'should be rated_by(user)' do
        user.rate(post, 5)
        expect(post.rated_by?(user).empty?).to be(false)
      end
    end

    describe 'has_rated' do
      it 'responds to has_rated' do
        expect(user).to respond_to(:has_rated?)
      end

      it 'has_rated returns values' do
        expect(user.has_rated?(post)).to_not be(false)
      end
    end
  end
end

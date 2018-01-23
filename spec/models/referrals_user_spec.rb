require 'rails_helper'

RSpec.describe ReferralsUser, type: :model do
  context 'associations' do
    let(:referrals_user) { create(:referrals_user) }
    let(:referring_user) { referrals_user.user }
    let(:referred_user)  { referrals_user.referred_user }

    it 'returns the right user' do
      expect(referrals_user.user).to be(referring_user)
      expect(referrals_user.referring_user).to be(referring_user)
    end

    it 'returns the right referred user' do
      expect(referrals_user.referred_user).to be(referred_user)
    end
  end

  context 'validations' do
    it 'does not allow more than one of the same referred user' do
      referred_user_id = create(:referrals_user).referred_user_id
      expect {
        create(:referrals_user, referred_user_id: referred_user_id)
      }.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  context 'callbacks' do
    let(:segment_analytics) { SegmentAnalytics.new }
    let(:track_calls) { segment_analytics.backend.track_calls }
    let(:identify_calls) { segment_analytics.backend.identify_calls }

    describe 'on create' do
      let!(:referrals_user) { create(:referrals_user) }

      it 'triggers an invited event' do
        expect(identify_calls.size).to eq(1)
        expect(identify_calls[0][:user_id]).to be(referrals_user.referrer.id)
        expect(track_calls[0][:event]).to be(SegmentIo::Events::REFERRAL_INVITED)
        expect(track_calls[0][:user_id]).to be(referrals_user.referrer.id)
        expect(track_calls[0][:properties][:referral_id]).to be(referrals_user.referral.id)
      end
    end

    describe 'on update when activated becomes true' do
      let!(:referrals_user) { create(:referrals_user) }
      before(:each) { referrals_user.update(activated: true) }

      it 'triggers an activated event' do
        expect(identify_calls.size).to eq(2)
        expect(identify_calls[1][:user_id]).to be(referrals_user.referrer.id)
        expect(track_calls[1][:event]).to be(SegmentIo::Events::REFERRAL_ACTIVATED)
        expect(track_calls[1][:user_id]).to be(referrals_user.referrer.id)
        expect(track_calls[1][:properties][:referral_id]).to be(referrals_user.referral.id)
      end

      it 'registers a user milestone' do
        expect(UserMilestone.where(
          user_id: referrals_user.referrer.id,
          milestone_id: Milestone.find_by(name: Milestone::TYPES[:refer_an_active_teacher])
        )).to exist
      end
    end
  end
end

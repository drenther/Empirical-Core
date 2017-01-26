FactoryGirl.define do
  factory :classroom_activity do
    unit {Unit.first || FactoryGirl.create(:unit)}
    classroom {Classroom.first || FactoryGirl.create(:classroom)}
	  factory :classroom_activity_with_activity do
	  	activity { Activity.first || FactoryGirl.create(:activity) }
	  end
    factory :classroom_activity_with_activity_sessions do
      after(:create) do |ca|
        create_list(:activity_session_with_random_completed_date, 5, classroom_activity: ca, state: 'finished')
      end
    end
    assigned_student_ids {[]}
  end
end

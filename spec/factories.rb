FactoryGirl.define do
  sequence :user_name do |n|
    "Tester-#{n}"
  end

  sequence :user_email do |n|
    "tester_#{n}@domain.com"
  end

  sequence :service_name do |n|
    "Service-#{n}"
  end

  sequence :trigger_name do |n|
    "Trigger-#{n}"
  end

  sequence :action_name do |n|
    "Action-#{n}"
  end

  sequence :task_name do |n|
    "Task-#{n}"
  end

  factory :user do
    name { Factory.next :user_name }
    email { Factory.next :user_email }
    password "foobar"
    password_confirmation "foobar"
  end

  factory :service do
    name { Factory.next :service_name }
    icon "file://./test.png"
    description "a test service"
    auth_type "none_auth"
    auth_data {}
    helper ""
  end

  factory :trigger do
    name { Factory.next :trigger_name }
    description "a test trigger"
    http_type "direct"
    http_method "get"
    period "*/10 * * * *"
    in_keys []
    source "http://test/trigger"
    header {}
    out_keys [:content]
    content_to_hash <<EOF
      parse_json content do |i|
        { :title => i["title"], :published => Time.parse(i["published"]) }
      end
EOF
    association :service
  end

  factory :action do
    name { Factory.next :action_name }
    description "a test action"
    http_type "direct"
    http_method "post"
    in_keys  []
    target "http://test/action"
    header {}
    body '"abc"'
    association :service
  end

  factory :task do
    name { Factory.next :task_name }
    association :user
    association :trigger
    trigger_params {}
    association :action
    action_params {}
    error_log {}
  end

  factory :service_meta_with_user do
    association :service
    association :user
    data {}
  end
end

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
    helper "abc"
  end

  factory :trigger do
    name { Factory.next :trigger_name }
    description "a test trigger"
    http_type "direct"
    http_method "get"
    params nil
    source "http://test/trigger"
    out_keys "content"
    content_to_hash "content"
    association :service
  end

  factory :action do
    name { Factory.next :action_name }
    description "a test action"
    http_type "direct"
    http_method "post"
    params nil
    target "http://test/action"
    body '"abc"'
    association :service
  end

  factory :task do
    name { Factory.next :task_name }
    association :user
    association :trigger
    trigger_params ""
    association :action
    action_params ""
  end
end

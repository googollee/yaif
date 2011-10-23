Factory.define :service do |s|
  s.name "TestService"
  s.description "a test service"
  s.auth_uri "http://www.weather.com.cn"
  s.auth_type "none_auth"
  s.auth_data {}
end

Factory.define :trigger do |t|
  t.name "test trigger"
  t.description "a test trigger"
  t.uri "http://test/trigger"
  t.service :service
  t.do "'a'"
end

Factory.define :action do |a|
  a.name "test action"
  a.description "a test action"
  a.uri "http://test/action"
  a.service :service
  a.do "'a'"
end

Factory.define :service do |s|
  s.name "TestService"
  s.icon "file://./test.png"
  s.description "a test service"
  s.auth_type "none_auth"
  s.auth_data {}
end

Factory.define :trigger do |t|
  t.name "test trigger"
  t.description "a test trigger"
  t.http_type "direct"
  t.http_method "get"
  t.params nil
  t.source "http://test/trigger"
  t.content_to_atom "content"
  t.service :service
end

Factory.define :action do |a|
  a.name "test action"
  a.description "a test action"
  a.http_type "direct"
  a.http_method "post"
  a.params nil
  a.source "http://test/action"
  a.body '"abc"'
  a.service :service
end

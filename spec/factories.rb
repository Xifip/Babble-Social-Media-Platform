# Get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Lloyd Chan"
  user.email                 "Lloyd@example.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

#define sequence behavior for :email 
Factory.sequence :email do |n|
  "testperson-#{n}@email.com"
end

#define micropost factory 
Factory.define :micropost do |micropost|
  micropost.content "A micropost was here"
  micropost.association :user
end
User.find_or_create_by!(email: 'test@email.com') do |u|
  u.password = 'password'
  u.username = 'テストアカウント１'
end

User.find_or_create_by!(email: 'test2@example.com') do |u|
  u.password = 'password'
  u.username = 'testuser2'
end
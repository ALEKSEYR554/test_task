# Create admin user
admin = User.create!(
  name: 'Admin',
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'admin'
)

# Create required tags (global)
Tag.create!(
  [
    { name: 'отчетность', color: '#FF6B6B', is_required: true },
    { name: 'операции', color: '#4ECDC4', is_required: true },
    { name: 'звонок', color: '#45B7D1', is_required: true }
  ]
)

puts "Seeds created: #{User.count} users, #{Tag.count} tags"
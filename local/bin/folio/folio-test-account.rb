#!/usr/bin/env ruby

credential = "test@test.test"

unless Folio::Account.where(email: credential).present?
  Folio::Account.create!(email: credential, password:  credential,
                         first_name: "test", last_name: "test",
                         role: "superuser")

  print "Created Folio::Account\n"
else
  print "Folio::Account exists\n"
end

# ===============================================================================
# Squared: {{{

if defined? Squared
  unless AdminUser.where(email: credential).present?
    AdminUser.create!(email: credential, password: credential,
                      first_name: "test", last_name: "test",
                      role: "superuser")

    print "Created AdminUser\n"
  else
    print "AdminUser exists\n"
  end

  Zone.all.each do |zone|
    unless User.where(email: credential, zone_id: zone.id).present?
      User.create!(email: credential, password: credential,
                   first_name: "test", last_name: "test",
                   nickname: "superuser", zone: zone)

      print "Created User\n"
    else
      print "User exists\n"
    end
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# MMSpektrum: {{{

if defined? Mmspektrum
  unless Folio::User.where(email: credential).present?
    Folio::User.create!(email: credential, password: credential,
                      first_name: "test", last_name: "test")

    print "Created Folio::User\n"
  else
    print "Folio::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Redside: {{{

if defined? Redside
  unless Folio::User.where(email: credential).present?
    Folio::User.create!(email: credential, password: credential,
                      first_name: "test", last_name: "test")

    print "Created Folio::User\n"
  else
    print "Folio::User exists\n"
  end
end

# }}}
# ===============================================================================

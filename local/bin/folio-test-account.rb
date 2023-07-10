#!/usr/bin/env ruby

# Folio::Account.create!(email: "vladislav.trefil@sinfin.cz", password: "ngfKz2FGyWw3", first_name: "Vladislav", last_name: "Trefil", role: "superuser")

credential = "test@test.test"

unless Folio::Account.where(email: credential).present?
  role = if Folio::Account.column_names.include? "roles"
    { roles: ["superuser"] }
  else
    { role: "superuser" }
  end

  Folio::Account.create!(email: credential, password:  credential,
                         first_name: "test", last_name: "test",
                         **role)

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

# ===============================================================================
# Infocz: {{{

if defined? Infocz
  unless Infocz::User.where(email: credential).present?
    Infocz::User.create!(email: credential, password: credential,
                         first_name: "test", last_name: "test")

    print "Created Infocz::User\n"
  else
    print "Infocz::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Acbcz: {{{

if defined? Acb
  if Acb::User.where(email: credential).blank?
    Acb::User.create!(email: credential,
                      password: credential,
                      first_name: 'test',
                      last_name: 'test',
                      confirmed_at: DateTime.current,
                      confirmation_sent_at: DateTime.current - 1.hour)

    print "Created Acb::User\n"
  else
    print "Acb::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Notesvilla: {{{

if defined? Notesvilla
  unless Notesvilla::User.where(email: credential).present?
    Notesvilla::User.create!(email: credential, password: credential,
                             first_name: "test", last_name: "test", phone: "724999999",
                             credits_non_withdrawable: 1000, credits_withdrawable: 1000)

    print "Created Notesvilla::User\n"
  else
    Notesvilla::User.where(email: credential).update(credits_non_withdrawable: 1000, credits_withdrawable: 1000)
    print "Notesvilla::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Nextpagemedia: {{{

if defined? Nextpagemedia
  unless Folio::User.where(email: credential).present?
    Folio::User.create!(email: credential, password: credential,
                        first_name: "test", last_name: "test", phone: "724999999",
                        confirmed_at: Time.now, confirmation_sent_at: 1.hour.ago, unconfirmed_email: false)

    print "Created Folio::User\n"
  else
    print "Folio::User exists\n"
  end
end

# }}}
# ===============================================================================

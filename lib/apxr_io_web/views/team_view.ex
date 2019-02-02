defmodule ApxrIoWeb.TeamView do
  use ApxrIoWeb, :view

  defp team_roles_selector() do
    Enum.map(team_roles(), fn {name, id, _title} ->
      {name, id}
    end)
  end

  defp team_roles() do
    [
      {"Admin", "admin", "This role has full control of the team"},
      {"Write", "write", "This role has project owner access to all team projects"},
      {"Read", "read", "This role can fetch all team projects"}
    ]
  end

  defp team_role(id) do
    Enum.find_value(team_roles(), fn {name, team_id, _title} ->
      if id == team_id do
        name
      end
    end)
  end

  def extract_params("key.generate", params) do
    Map.to_list(%{name: params["key"]["name"]})
  end

  def extract_params("key.remove", params) do
    Map.to_list(%{name: params["key"]["name"]})
  end

  def extract_params("owner.add", params) do
    Map.to_list(%{
      project: params["project"]["name"],
      level: params["level"],
      user: params["user"]["username"]
    })
  end

  def extract_params("owner.remove", params) do
    Map.to_list(%{
      project: params["project"]["name"],
      level: params["level"],
      user: params["user"]["username"]
    })
  end

  def extract_params("release.publish", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("release.revert", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("release.retire", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("release.unretire", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("email.add", params) do
    Map.to_list(%{email: params["email"], primary: params["primary"]})
  end

  def extract_params("email.remove", params) do
    Map.to_list(%{email: params["email"], primary: params["primary"]})
  end

  def extract_params("email.primary", params) do
    Map.to_list(%{
      old_email: params["old_email"]["email"],
      new_email: params["new_email"]["email"]
    })
  end

  def extract_params("user.create", params) do
    Map.to_list(%{user: params["user"]["username"]})
  end

  def extract_params("user.update", params) do
    Map.to_list(%{user: params["user"]["username"]})
  end

  def extract_params("team.create", params) do
    Map.to_list(%{team: params["team"]["name"]})
  end

  def extract_params("team.member.add", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.member.remove", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.member.role", params) do
    Map.to_list(%{
      team: params["team"]["name"],
      user: params["user"]["username"],
      role: params["role"]
    })
  end

  def extract_params("experiment.create", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.start", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.pause", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.continue", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.stop", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.update", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("experiment.delete", params) do
    Map.to_list(%{project: params["project"]["name"], version: params["release"]["version"]})
  end

  def extract_params("artifact.publish", params) do
    Map.to_list(%{project: params["project"]["name"], artifact: params["artifact"]["name"]})
  end

  def extract_params("artifact.unpublish", params) do
    Map.to_list(%{project: params["project"]["name"], artifact: params["artifact"]["name"]})
  end

  def extract_params("artifact.delete", params) do
    Map.to_list(%{project: params["project"]["name"], artifact: params["artifact"]["name"]})
  end

  def extract_params("team.billing.create", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.billing.update", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.billing.cancel", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.billing.change_plan", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.billing.add_seats", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.billing.remove_seats", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params("team.billing.pay_invoice", params) do
    Map.to_list(%{team: params["team"]["name"], user: params["user"]["username"]})
  end

  def extract_params(_unknown_action, _params) do
    Map.to_list(%{})
  end

  defp default_billing_emails(user, billing_email) do
    emails =
      user.emails
      |> Enum.filter(& &1.verified)
      |> Enum.map(& &1.email)

    [billing_email | emails]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  # From ApxrIo.Billing.Country
  @country_codes [
    {"AD", "Andorra"},
    {"AE", "United Arab Emirates"},
    {"AF", "Afghanistan"},
    {"AG", "Antigua and Barbuda"},
    {"AI", "Anguilla"},
    {"AL", "Albania"},
    {"AM", "Armenia"},
    {"AO", "Angola"},
    {"AQ", "Antarctica"},
    {"AR", "Argentina"},
    {"AS", "American Samoa"},
    {"AT", "Austria"},
    {"AU", "Australia"},
    {"AW", "Aruba"},
    {"AX", "Åland Islands"},
    {"AZ", "Azerbaijan"},
    {"BA", "Bosnia and Herzegovina"},
    {"BB", "Barbados"},
    {"BD", "Bangladesh"},
    {"BE", "Belgium"},
    {"BF", "Burkina Faso"},
    {"BG", "Bulgaria"},
    {"BH", "Bahrain"},
    {"BI", "Burundi"},
    {"BJ", "Benin"},
    {"BL", "Saint Barthélemy"},
    {"BM", "Bermuda"},
    # Brunei Darussalam
    {"BN", "Brunei"},
    # Bolivia, Plurinational State
    {"BO", "Bolivia"},
    # Bonaire, Sint Eustatius and Saba
    {"BQ", "Bonaire"},
    {"BR", "Brazil"},
    {"BS", "Bahamas"},
    {"BT", "Bhutan"},
    {"BV", "Bouvet Island"},
    {"BW", "Botswana"},
    {"BY", "Belarus"},
    {"BZ", "Belize"},
    {"CA", "Canada"},
    {"CC", "Cocos (Keeling) Islands"},
    {"CD", "Congo, the Democratic Republic of the"},
    {"CF", "Central African Republic"},
    {"CG", "Congo"},
    {"CH", "Switzerland"},
    {"CI", "Côte d'Ivoire"},
    {"CK", "Cook Islands"},
    {"CL", "Chile"},
    {"CM", "Cameroon"},
    {"CN", "China"},
    {"CO", "Colombia"},
    {"CR", "Costa Rica"},
    {"CU", "Cuba"},
    {"CV", "Cabo Verde"},
    {"CW", "Curaçao"},
    {"CX", "Christmas Island"},
    {"CY", "Cyprus"},
    # Czechia (Changed for Stripe compatability)
    {"CZ", "Czech Republic"},
    {"DE", "Germany"},
    {"DJ", "Djibouti"},
    {"DK", "Denmark"},
    {"DM", "Dominica"},
    {"DO", "Dominican Republic"},
    {"DZ", "Algeria"},
    {"EC", "Ecuador"},
    {"EE", "Estonia"},
    {"EG", "Egypt"},
    {"EH", "Western Sahara"},
    {"ER", "Eritrea"},
    {"ES", "Spain"},
    {"ET", "Ethiopia"},
    {"FI", "Finland"},
    {"FJ", "Fiji"},
    # Falkland Islands (Malvinas)
    {"FK", "Falkland Island"},
    # Micronesia, Federated States of
    {"FM", "Micronesia"},
    {"FO", "Faroe Islands"},
    {"FR", "France"},
    {"GA", "Gabon"},
    # United Kingdom of Great Britain and Northern Ireland
    {"GB", "United Kingdom"},
    {"GD", "Grenada"},
    {"GE", "Georgia"},
    {"GF", "French Guiana"},
    {"GG", "Guernsey"},
    {"GH", "Ghana"},
    {"GI", "Gibraltar"},
    {"GL", "Greenland"},
    {"GM", "Gambia"},
    {"GN", "Guinea"},
    {"GP", "Guadeloupe"},
    {"GQ", "Equatorial Guinea"},
    {"GR", "Greece"},
    # South Georgia and the South Sandwich Islands
    {"GS", "South Georgia"},
    {"GT", "Guatemala"},
    {"GU", "Guam"},
    {"GW", "Guinea-Bissau"},
    {"GY", "Guyana"},
    {"HK", "Hong Kong"},
    {"HM", "Heard Island and McDonald Islands"},
    {"HN", "Honduras"},
    {"HR", "Croatia"},
    {"HT", "Haiti"},
    {"HU", "Hungary"},
    {"ID", "Indonesia"},
    {"IE", "Ireland"},
    {"IL", "Israel"},
    {"IM", "Isle of Man"},
    {"IN", "India"},
    {"IO", "British Indian Ocean Territory"},
    {"IQ", "Iraq"},
    # Iran, Islamic Republic
    {"IR", "Iran"},
    {"IS", "Iceland"},
    {"IT", "Italy"},
    {"JE", "Jersey"},
    {"JM", "Jamaica"},
    {"JO", "Jordan"},
    {"JP", "Japan"},
    {"KE", "Kenya"},
    {"KG", "Kyrgyzstan"},
    {"KH", "Cambodia"},
    {"KI", "Kiribati"},
    {"KM", "Comoros"},
    {"KN", "Saint Kitts and Nevis"},
    {"KP", "Korea, Democratic People's Republic of"},
    {"KR", "Korea, Republic of"},
    {"KW", "Kuwait"},
    {"KY", "Cayman Islands"},
    {"KZ", "Kazakhstan"},
    # Lao People's Democratic Republic
    {"LA", "Laos"},
    {"LB", "Lebanon"},
    {"LC", "Saint Lucia"},
    {"LI", "Liechtenstein"},
    {"LK", "Sri Lanka"},
    {"LR", "Liberia"},
    {"LS", "Lesotho"},
    {"LT", "Lithuania"},
    {"LU", "Luxembourg"},
    {"LV", "Latvia"},
    {"LY", "Libya"},
    {"MA", "Morocco"},
    {"MC", "Monaco"},
    {"MD", "Moldova , Republic"},
    {"ME", "Montenegro"},
    # Saint Martin (French part)
    {"MF", "Saint Martin"},
    {"MG", "Madagascar"},
    {"MH", "Marshall Islands"},
    {"MK", "Macedonia"},
    {"ML", "Mali"},
    {"MM", "Myanmar"},
    {"MN", "Mongolia"},
    {"MO", "Macao"},
    {"MP", "Northern Mariana Islands"},
    {"MQ", "Martinique"},
    {"MR", "Mauritania"},
    {"MS", "Montserrat"},
    {"MT", "Malta"},
    {"MU", "Mauritius"},
    {"MV", "Maldives"},
    {"MW", "Malawi"},
    {"MX", "Mexico"},
    {"MY", "Malaysia"},
    {"MZ", "Mozambique"},
    {"NA", "Namibia"},
    {"NC", "New Caledonia"},
    {"NE", "Niger"},
    {"NF", "Norfolk Island"},
    {"NG", "Nigeria"},
    {"NI", "Nicaragua"},
    {"NL", "Netherlands"},
    {"NO", "Norway"},
    {"NP", "Nepal"},
    {"NR", "Nauru"},
    {"NU", "Niue"},
    {"NZ", "New Zealand"},
    {"OM", "Oman"},
    {"PA", "Panama"},
    {"PE", "Peru"},
    {"PF", "French Polynesia"},
    {"PG", "Papua New Guinea"},
    {"PH", "Philippines"},
    {"PK", "Pakistan"},
    {"PL", "Poland"},
    {"PM", "Saint Pierre and Miquelon"},
    {"PN", "Pitcairn"},
    {"PR", "Puerto Rico"},
    # Palestine, State of
    {"PS", "Palestin"},
    {"PT", "Portugal"},
    {"PW", "Palau"},
    {"PY", "Paraguay"},
    {"QA", "Qatar"},
    {"RE", "Réunion"},
    {"RO", "Romania"},
    {"RS", "Serbia"},
    # Russian Federation
    {"RU", "Russia"},
    {"RW", "Rwanda"},
    {"SA", "Saudi Arabia"},
    {"SB", "Solomon Islands"},
    {"SC", "Seychelles"},
    {"SD", "Sudan"},
    {"SE", "Sweden"},
    {"SG", "Singapore"},
    {"SH", "Saint Helena, Ascension and Tristan da Cunha"},
    {"SI", "Slovenia"},
    {"SJ", "Svalbard and Jan Mayen"},
    {"SK", "Slovakia"},
    {"SL", "Sierra Leone"},
    {"SM", "San Marino"},
    {"SN", "Senegal"},
    {"SO", "Somalia"},
    {"SR", "Suriname"},
    {"SS", "South Sudan"},
    {"ST", "Sao Tome and Principe"},
    {"SV", "El Salvador"},
    # Sint Maarten (Dutch part)
    {"SX", "Sint Maarten"},
    # Syrian Arab Republic
    {"SY", "Syria"},
    {"SZ", "Swaziland"},
    {"TC", "Turks and Caicos Islands"},
    {"TD", "Chad"},
    {"TF", "French Southern Territories"},
    {"TG", "Togo"},
    {"TH", "Thailand"},
    {"TJ", "Tajikistan"},
    {"TK", "Tokelau"},
    {"TL", "Timor-Leste"},
    {"TM", "Turkmenistan"},
    {"TN", "Tunisia"},
    {"TO", "Tonga"},
    {"TR", "Turkey"},
    {"TT", "Trinidad and Tobago"},
    {"TV", "Tuvalu"},
    # Taiwan, Province of China
    {"TW", "Taiwan"},
    # Tanzania, United Republic of
    {"TZ", "Tanzania"},
    {"UA", "Ukraine"},
    {"UG", "Uganda"},
    {"UM", "United States Minor Outlying Islands"},
    # United States of America
    {"US", "United States"},
    {"UY", "Uruguay"},
    {"UZ", "Uzbekistan"},
    {"VA", "Holy See"},
    {"VC", "Saint Vincent and the Grenadines"},
    # Venezuela, Bolivarian Republic of
    {"VE", "Venezuela"},
    # Virgin Islands, British
    {"VG", "British Virgin Islands"},
    # Virgin Islands, U.S.
    {"VI", "United States Virgin Islands"},
    {"VN", "Viet Nam"},
    {"VU", "Vanuatu"},
    {"WF", "Wallis and Futuna"},
    {"WS", "Samoa"},
    {"YE", "Yemen"},
    {"YT", "Mayotte"},
    {"ZA", "South Africa"},
    {"ZM", "Zambia"},
    {"ZW", "Zimbabwe"}
  ]

  defp countries() do
    unquote([{"", ""}] ++ Enum.sort_by(@country_codes, &elem(&1, 1)))
  end
end

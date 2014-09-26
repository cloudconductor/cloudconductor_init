bootstrap_helper = BootstrapHelper.new(self)

# checkout optional patterns
bootstrap_helper.optional_patterns.each do |pattern|
  git "/opt/cloudconductor/patterns/#{pattern[:pattern_name]}" do
    repository "#{pattern[:url]}"
    revision "#{pattern[:revision]}"
    action :checkout
  end
end

# TODO: setup consul services information of optional patterns

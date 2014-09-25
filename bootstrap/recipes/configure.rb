bootstrap_helper = BootstrapHelper.new(self)

# clone optional patterns
bootstrap_helper.getOptionalPatterns.each do |pattern|
  git "/opt/cloudconductor/patterns/#{pattern[:pattern_name]}" do
    repository "#{pattern[:url]}"
    revision "#{pattern[:revision]}"
    action :checkout
  end
end

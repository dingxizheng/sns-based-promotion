json.array!(subscriptions) do |subscription|
  json.partial! :partial => 'subscriptions/subscription', :locals => { :subscription => subscription }
end

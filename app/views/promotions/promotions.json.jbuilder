json.array!(promotions) do |promotion|
  json.partial! :partial => 'promotions/listitem', :locals => { :promotion => promotion }
end

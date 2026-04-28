module ApplicationHelper
  # ISSUE-41: 記録ありのみ達成/未達で色分け。未記録（nil）は中立。
  def calendar_day_link_classes(log)
    base = "block rounded-md p-1 text-left text-sm font-medium outline-none focus-visible:ring-2"

    if log.nil?
      "#{base} text-gray-900 ring-emerald-600 hover:bg-gray-50"
    elsif log.met_daily_target?
      "#{base} border border-emerald-200 bg-emerald-50 text-emerald-900 ring-emerald-600 hover:bg-emerald-100"
    else
      "#{base} border border-red-200 bg-red-50 text-red-900 ring-red-600 hover:bg-red-100"
    end
  end
end

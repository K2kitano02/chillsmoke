module ApplicationHelper
  # ISSUE-41: 記録ありのみ達成/未達で色分け。未記録（nil）は中立。
  def calendar_day_link_classes(log)
    base = "block rounded-md p-1 text-left text-sm font-medium outline-none focus-visible:ring-2"

    if log.nil?
      "#{base} text-stone-300 ring-amber-400 hover:bg-[#292823]"
    elsif log.met_daily_target?
      "#{base} border border-emerald-200 border-emerald-300/20 bg-emerald-50 bg-emerald-400/10 text-emerald-200 ring-amber-400 hover:bg-emerald-400/15"
    else
      "#{base} border border-red-200 border-red-400/30 bg-red-50 bg-red-950/40 text-red-200 ring-red-300 hover:bg-red-950/60"
    end
  end
end

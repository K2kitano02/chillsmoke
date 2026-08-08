import { Controller } from "@hotwired/stimulus"
import {
  BarController,
  BarElement,
  CategoryScale,
  Chart,
  LineController,
  LineElement,
  LinearScale,
  PointElement,
  Tooltip
} from "chart.js"

Chart.register(
  BarController,
  BarElement,
  CategoryScale,
  LineController,
  LineElement,
  LinearScale,
  PointElement,
  Tooltip
)

export default class extends Controller {
  static targets = ["tab", "panel", "smokingCanvas", "savingsCanvas"]
  static values = {
    labels: Array,
    smokingCounts: Array,
    targetCounts: Array,
    savedYen: Array
  }

  connect() {
    this.charts = []
    this.drawCharts()
  }

  disconnect() {
    this.charts.forEach((chart) => chart.destroy())
  }

  select(event) {
    this.activate(event.currentTarget)
  }

  navigate(event) {
    const currentIndex = this.tabTargets.indexOf(event.currentTarget)
    let nextIndex

    switch (event.key) {
      case "ArrowRight":
      case "ArrowDown":
        nextIndex = (currentIndex + 1) % this.tabTargets.length
        break
      case "ArrowLeft":
      case "ArrowUp":
        nextIndex = (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length
        break
      case "Home":
        nextIndex = 0
        break
      case "End":
        nextIndex = this.tabTargets.length - 1
        break
      default:
        return
    }

    event.preventDefault()
    this.tabTargets[nextIndex].focus()
    this.activate(this.tabTargets[nextIndex])
  }

  activate(selectedTab) {
    const selectedPanel = selectedTab.dataset.reportTabsPanelParam

    this.tabTargets.forEach((tab) => {
      const selected = tab === selectedTab
      tab.setAttribute("aria-selected", selected.toString())
      tab.tabIndex = selected ? 0 : -1
      tab.classList.toggle("bg-amber-400", selected)
      tab.classList.toggle("text-stone-950", selected)
      tab.classList.toggle("shadow-sm", selected)
      tab.classList.toggle("text-stone-300", !selected)
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.panelName !== selectedPanel
    })

    requestAnimationFrame(() => this.charts.forEach((chart) => chart.resize()))
  }

  drawCharts() {
    if (this.hasSmokingCanvasTarget) {
      this.charts.push(new Chart(this.smokingCanvasTarget, this.smokingChartConfig()))
    }

    if (this.hasSavingsCanvasTarget) {
      this.charts.push(new Chart(this.savingsCanvasTarget, this.savingsChartConfig()))
    }
  }

  smokingChartConfig() {
    return {
      type: "line",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "実績",
            data: this.smokingCountsValue,
            borderColor: "rgba(251, 191, 36, 0.72)",
            borderWidth: 2.5,
            pointBackgroundColor: (context) => this.smokingPointColor(context.dataIndex),
            pointBorderColor: (context) => this.smokingPointColor(context.dataIndex),
            pointBorderWidth: 2,
            pointRadius: 5,
            pointHoverRadius: 7,
            spanGaps: false,
            tension: 0.2
          },
          {
            label: "目標本数",
            data: this.targetCountsValue,
            borderColor: "#d6d3d1",
            backgroundColor: "#d6d3d1",
            borderDash: [6, 5],
            borderWidth: 2,
            pointRadius: 3,
            pointHoverRadius: 5,
            spanGaps: false,
            tension: 0.2
          }
        ]
      },
      options: this.chartOptions("本", true)
    }
  }

  savingsChartConfig() {
    return {
      type: "bar",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "節約額",
            data: this.savedYenValue,
            backgroundColor: (context) => context.raw === 0 ? "rgba(251, 113, 133, 0.85)" : "rgba(52, 211, 153, 0.76)",
            borderColor: (context) => context.raw === 0 ? "#fb7185" : "#6ee7b7",
            borderWidth: 1,
            borderRadius: 5,
            borderSkipped: false,
            minBarLength: 3
          }
        ]
      },
      options: this.chartOptions("円")
    }
  }

  smokingPointColor(index) {
    const smokingCount = this.smokingCountsValue[index]
    const targetCount = this.targetCountsValue[index]

    if (smokingCount === null || targetCount === null) return "transparent"

    return smokingCount <= targetCount ? "#34d399" : "#fb7185"
  }

  chartOptions(unit, smokingChart = false) {
    return {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { intersect: false, mode: "index" },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: "rgba(9, 9, 8, 0.96)",
          titleColor: "#fafaf9",
          bodyColor: "#e7e5e4",
          borderColor: "rgba(255, 255, 255, 0.14)",
          borderWidth: 1,
          padding: 12,
          callbacks: {
            label: (context) => this.tooltipLabel(context, unit),
            afterBody: (items) => smokingChart ? this.smokingComparison(items) : []
          }
        }
      },
      scales: {
        x: {
          grid: { display: false },
          ticks: {
            color: "#d6d3d1",
            autoSkip: true,
            maxRotation: 0,
            maxTicksLimit: 5,
            padding: 8,
            font: { size: 12, weight: "600" }
          }
        },
        y: {
          beginAtZero: true,
          grid: { color: "rgba(255, 255, 255, 0.1)" },
          ticks: { color: "#d6d3d1", precision: 0, padding: 8, font: { size: 12, weight: "600" } }
        }
      }
    }
  }

  tooltipLabel(context, unit) {
    if (context.raw === null) return `${context.dataset.label}: 未記録`

    return `${context.dataset.label}: ${context.parsed.y}${unit}`
  }

  smokingComparison(items) {
    if (items.length === 0) return []

    const index = items[0].dataIndex
    const smokingCount = this.smokingCountsValue[index]
    const targetCount = this.targetCountsValue[index]

    if (smokingCount === null || targetCount === null) return []
    if (smokingCount <= targetCount) return [`目標以内: ${targetCount - smokingCount}本の余裕`]

    return [`目標超過: ${smokingCount - targetCount}本多い`]
  }

}

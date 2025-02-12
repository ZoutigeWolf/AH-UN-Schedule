//
//  InsightsView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 17/03/2024.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @State var date: Date = Date.now
    @State var view: InsightViewMode = .stats
    @State var insight: Insight? = nil
    
    let placeholderChartData: [Int: Double] = [
        0: 0,
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    VStack {
                        MonthController(date: $date)
                            .padding(.top)
                            .padding(.horizontal)
                            .frame(width: geometry.size.width)
                        
                        Picker("View", selection: $view) {
                            ForEach(InsightViewMode.allCases) { v in
                                Text(v.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .frame(width: geometry.size.width)
                    }
                    .background(Color(uiColor: UIColor.systemGray6))
                    
                    if view == .stats {
                        ScrollView {
                            VStack {
                                VStack {
                                    HStack {
                                        StatBox(label: Text("Days worked"), value: Text("\(insight?.days ?? 0)"), size: 170)
                                        StatBox(label: Text("Time worked"), value: Text("\(DateUtils.parseHours(insight?.hours ?? 0).0)h \(DateUtils.parseHours(insight?.hours ?? 0).1)m"), size: 170)

                                    }
                                    
                                    StatBox(label: Text("Estimated salary"), value: Text(insight?.salary ?? 0, format: .currency(code: "EUR")), size: 348)
                                    
                                    Spacer()
                                }
                                
                                VStack {
                                    Text("Average shift length")
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 14)
                                    
                                    Chart {
                                        ForEach(insight?.averageShiftLength.sorted { $0.key < $1.key } ?? placeholderChartData.sorted { $0.key < $1.key }, id: \.key) { day, length in
                                            BarMark(
                                                x: .value("Day", DateUtils.getDayName(day)),
                                                y: .value("Hours", length)
                                            )
                                        }
                                    }
                                }
                                .padding()
                                .frame(width: 348, height: 300)
                                .background(Color(uiColor: .systemGray6))
                                .cornerRadius(6)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                        }
                        .refreshable {
                            reload()
                        }
                        
                        Spacer()
                    } else if view == .shifts {
                        if let insight = insight {
                            List {
                                Section {
                                    ForEach(insight.shifts.sorted { $0.start < $1.start }, id: \.id) { shift in
                                        NavigationLink(destination: EditShiftView(shift: shift)) {
                                            VStack(alignment: .leading) {
                                                Text(shift.start.formatted(date: .complete, time: .omitted))
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(shift.canceled ? .secondary : .primary)
                                                    .strikethrough(shift.canceled, color: .secondary)
                                                
                                                HStack {
                                                    Text(shift.start.hourAndMinute())
                                                        .foregroundStyle(shift.canceled ? .secondary : .primary)
                                                        .strikethrough(shift.canceled, color: .secondary)
                                                    
                                                    if shift.end != nil && !shift.canceled {
                                                        Text("-")
                                                            .foregroundStyle(.secondary)
                                                        
                                                        Text(shift.end!.hourAndMinute())
                                                            .foregroundStyle(shift.canceled ? .secondary : .primary)
                                                            .strikethrough(shift.canceled, color: .secondary)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } header: {
                                    Text("\(insight.shifts.count) Shifts")
                                }
                            }
                            .refreshable {
                                reload()
                            }
                        }
                    }
                }
                .onAppear() {
                    reload()
                }
                .onChange(of: date) { _ in
                    reload()
                }
            }
        }
    }
    
    func reload() {
        Insights.getMonthlyStats(year: DateUtils.getDateComponent(date, .year), month: DateUtils.getDateComponent(date, .month)) { insight in
            DispatchQueue.main.async {
                self.insight = insight
            }
        }
    }
}

enum InsightViewMode: String, CaseIterable, Identifiable {
    case stats, shifts
    var id: Self { self }
}

#Preview {
    InsightsView()
}

////
////  InsightsView.swift
////  AH-UN Schedule
////
////  Created by ZoutigeWolf on 17/03/2024.
////
//
//import SwiftUI
//import Charts
//
//struct InsightsView: View {
//    @State var date: Date = Date.now
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                MonthController(date: $date)
//                    .padding()
//                    .frame(width: geometry.size.width)
//                    .background(Color(uiColor: UIColor.systemGray6))
//                
//                ScrollView {
//                    VStack {
//                        VStack {
//                            HStack {
//                                StatBox(label: Text("Days worked"), value: Text("\(Insights.daysWorkedInMonth(date: date)) / \(DateUtils.numberOfDays(inMonth: date))"), size: 170)
//                                StatBox(label: Text("Hours worked"), value: Text("\(Insights.timeWorkedInMonth(date: date).hour)"), size: 170)
//
//                            }
//                            
//                            StatBox(label: Text("Estimated salary"), value: Text(Insights.earningsInMonth(date: date), format: .currency(code: "EUR")), size: 348)
//                            
//                            Spacer()
//                        }
//                        
//                        VStack {
//                            Text("Average shift length")
//                                .foregroundStyle(.secondary)
//                                .padding(.horizontal, 14)
//                            
//                            Chart {
//                                ForEach(Insights.averageShiftLength(date: date).sorted { $0.key < $1.key }, id: \.key) { day, length in
//                                    BarMark(
//                                        x: .value("Day", DateUtils.getDayName(day)),
//                                        y: .value("Hours", length)
//                                    )
//                                }
//                            }
//                        }
//                        .padding()
//                        .frame(width: 348, height: 300)
//                        .background(Color(uiColor: .systemGray6))
//                        .cornerRadius(6)
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 10)
//                }
//
//                Spacer()
//            }
//        }
//    }
//}
//
//#Preview {
//    InsightsView()
//}

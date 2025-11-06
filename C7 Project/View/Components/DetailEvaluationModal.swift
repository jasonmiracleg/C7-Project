//
//  DetailEvaluationModal.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 03/11/25.
//

import SwiftUI

struct DetailEvaluationModal: View {
    let detail: GrammarEvaluationDetail
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Spacer() // Equal space on left

            Text("Detail Evaluation")
                .font(.headline)

            Spacer() // Equal space on right
        }
        .overlay(alignment: .trailing) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24))
                    .foregroundStyle(.black)
                    .clipShape(Circle())
            }
            .buttonStyle(.glass)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Table-like card
                VStack(spacing: 0) {
                    Grid(
                        alignment: .topLeading,
                        horizontalSpacing: 0,
                        verticalSpacing: 0
                    ) {
                        // Header
                        GridRow {
                            Text("Spoken Sentence")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    Color(UIColor.secondarySystemBackground)
                                )

                            Divider()
                                .frame(width: 1)
                                .background(Color(UIColor.separator))

                            Text("Correct Grammar")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    Color(UIColor.secondarySystemBackground)
                                )
                        }

                        // Separator spanning both columns
                        GridRow {
                            Rectangle()
                                .fill(Color(UIColor.separator))
                                .frame(height: 1)
                                .gridCellColumns(3)
                        }

                        // Content row
                        GridRow {
                            Text(detail.spokenSentence)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .textSelection(.enabled)

                            Divider()
                                .frame(width: 1)
                                .background(Color(UIColor.separator))

                            Text(detail.correctedSentence)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .textSelection(.enabled)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(UIColor.separator), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                // Explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explanation")
                        .font(.title3.weight(.bold))

                    Text(detail.evaluationDetail)
                        .font(.body)
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
            }
            .padding()
        }

    }
}

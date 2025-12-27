import SwiftUI

/// Sheet view for selecting AWS certification exam
struct ExamSelectorView: View {
    @Binding var selectedExam: QuestionSet
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("AWS Certifications")) {
                    ForEach(QuestionSet.allCases, id: \.self) { exam in
                        Button(action: {
                            selectedExam = exam
                            isPresented = false
                        }) {
                            HStack {
                                Text(exam.title)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedExam == exam {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Exam")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

#Preview {
    @State var selectedExam = QuestionSet.cloudPractitioner
    @State var isPresented = true

    return ExamSelectorView(selectedExam: $selectedExam, isPresented: $isPresented)
}

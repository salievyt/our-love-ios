import SwiftUI

// MARK: - Questions View Backend

struct QuestionsViewBackend: View {
    @EnvironmentObject var viewModel: QuestionsViewModel
    @EnvironmentObject var authService: AuthServiceImpl
    @State private var showingAnswerSheet = false
    @State private var answeringAsPartner1 = true
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else if let error = viewModel.error {
                    errorView(error: error)
                } else {
                    VStack(spacing: 20) {
                        // Today's question
                        if let question = viewModel.todayQuestion {
                            todayQuestionCard(question)
                        }
                        
                        // Previous questions
                        if !viewModel.questionHistory.isEmpty {
                            previousQuestionsSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(
                LinearGradient(colors: [.blue.opacity(0.03), .purple.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Вопрос дня")
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showingAnswerSheet) {
                answerSheet
            }
        }
    }
    
    // MARK: - Today's Question
    private func todayQuestionCard(_ question: QuestionOfTheDay) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.bubble.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                )
            
            Text("Вопрос дня")
                .font(.caption.weight(.semibold))
                .foregroundColor(.blue)
            
            Text(question.question)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
            
            // Answer status
            VStack(spacing: 12) {
                answerStatusRow(label: "Вы", isAnswered: question.partner1Answered)
                answerStatusRow(label: "Партнёр", isAnswered: question.partner2Answered)
            }
            
            if !question.bothAnswered {
                Button {
                    answeringAsPartner1 = !question.partner1Answered
                    viewModel.answerText = ""
                    showingAnswerSheet = true
                } label: {
                    Text(question.partner1Answered ? "Посмотреть ответы" : "Ответить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            if question.bothAnswered {
                answersRevealedSection(question)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Answer Status
    private func answerStatusRow(label: String, isAnswered: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline.weight(.medium))
                .frame(width: 80, alignment: .leading)
            
            if isAnswered {
                Label("Ответили", systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else {
                Label("Ожидаем ответ", systemImage: "hourglass")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Answers Revealed
    private func answersRevealedSection(_ question: QuestionOfTheDay) -> some View {
        VStack(spacing: 16) {
            Divider()
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
                Text("Ответы раскрыты")
                    .font(.headline)
                    .foregroundColor(.purple)
                Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
            }
            
            if let answer1 = question.answers.first(where: { $0.user == authService.currentUser?.id }),
               answer1.text.isEmpty == false {
                answerBubble(label: "Вы", answer: answer1.text, isPartner1: true)
            } else if question.partner1Answered {
                answerBubble(label: "Вы", answer: "(ответ скрыт)", isPartner1: true)
            }
            
            if let answer2 = question.answers.first(where: { $0.user != authService.currentUser?.id }),
               answer2.text.isEmpty == false {
                answerBubble(label: "Партнёр", answer: answer2.text, isPartner1: false)
            } else if question.partner2Answered {
                answerBubble(label: "Партнёр", answer: "(ответ скрыт)", isPartner1: false)
            }
        }
    }
    
    private func answerBubble(label: String, answer: String, isPartner1: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(isPartner1 ? .blue : .purple)
            
            Text(answer)
                .font(.subheadline)
                .padding(12)
                .background(isPartner1 ? Color.blue.opacity(0.08) : Color.purple.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Previous Questions
    private var previousQuestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История вопросов")
                .font(.headline)
            
            ForEach(viewModel.questionHistory) { question in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: question.bothAnswered ? "checkmark.circle.fill" : "circle.dashed")
                            .foregroundColor(question.bothAnswered ? .green : .orange)
                        
                        Text(question.question)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(question.dateAssigned, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                if question != viewModel.questionHistory.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Answer Sheet
    private var answerSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let question = viewModel.todayQuestion {
                    Text(question.question)
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextEditor(text: $viewModel.answerText)
                        .frame(height: 200)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await viewModel.submitAnswer()
                        }
                    } label: {
                        Text("Отправить ответ")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(viewModel.answerText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal)
                }
            }
            .padding(.top)
            .navigationTitle("Ваш ответ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { showingAnswerSheet = false }
                }
            }
        }
    }
    
    // MARK: - Error View
    private func errorView(error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Ошибка загрузки")
                .font(.headline)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Повторить") {
                Task {
                    await viewModel.loadData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    QuestionsViewBackend()
        .environmentObject(QuestionsViewModel(questionUseCase: DIContainer.shared.questionUseCase))
        .environmentObject(DIContainer.shared.authService)
}

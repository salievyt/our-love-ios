//  QuestionsView.swift
//  Our Love

import SwiftUI
import SwiftData

struct QuestionsView: View {
    @Query private var questions: [QuestionOfTheDay]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAnswerSheet = false
    @State private var currentAnswer = ""
    @State private var answeringAsPartner1 = true
    
    static let questionPool: [String] = [
        "Что ты больше всего ценишь в наших отношениях?",
        "Какой момент с начала отношений был самым запоминающимся?",
        "Что бы ты хотел(а) изменить в нашем совместном будущем?",
        "Какая наша совместная фотография тебе нравится больше всего?",
        "Что тебя рассмешило сегодня больше всего?",
        "Какое блюдо напоминает тебе обо мне?",
        "Что бы ты хотел(а) сделать вместе, но мы ещё не сделали?",
        "Каким ты видишь нас через 5 лет?",
        "Что из того, что я делаю, делает тебя счастливее?",
        "Какую книгу или фильм ты хотел(а) бы обсудить со мной?",
        "Чему я тебя научил(а)?",
        "Какой комплимент тебе запомнился больше всего?",
        "Что для тебя «идеальный день» вместе?",
        "Какая твоя любимая привычка, которая у нас появилась?",
        "Если бы мы могли отправиться в любое путешествие, куда бы мы поехали?",
        "Что самое милое я делаю, даже не осознавая этого?",
        "О чём ты мечтаешь в последнее время?",
        "Что бы ты сказал(а) себе из прошлого в начале наших отношений?",
        "Как ты понимаешь, что я люблю тебя?",
        "Что тебе нравится в том, как мы ссоримся и миримся?",
        "Какой запах ассоциируется у тебя с нашими отношениями?",
        "Что было самым неожиданным в наших отношениях?",
        "Чем ты гордишься в наших отношениях?",
        "Какую песню можно назвать «нашей» и почему?",
        "Что бы ты хотел(а) сказать мне прямо сейчас?",
        "Что тебе нравится в том, как я выгляжу утром?",
        "Какое совместное достижение для тебя самое важное?",
        "Что нас делает особенной парой?",
        "Какой момент из наших отношений ты хотел(а) бы пережить снова?",
        "Что тебе нравится в том, как мы поддерживаем друг друга?",
    ]
    
    var todayQuestion: QuestionOfTheDay? {
        let today = Calendar.current.startOfDay(for: Date())
        return questions.first { Calendar.current.isDate($0.dateAssigned, inSameDayAs: today) }
    }
    
    var previousQuestions: [QuestionOfTheDay] {
        questions.filter { q in
            guard let qDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: q.dateAssigned) else { return false }
            return qDate < Calendar.current.startOfDay(for: Date())
        }.sorted(by: { $0.dateAssigned > $1.dateAssigned })
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Today's question
                    if let question = todayQuestion {
                        todayQuestionCard(question)
                    } else {
                        newQuestionCard
                    }
                    
                    // Previous questions
                    if !previousQuestions.isEmpty {
                        previousQuestionsSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(colors: [.blue.opacity(0.03), .purple.opacity(0.03)],
                              startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Вопрос дня")
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
                answerStatusRow(label: "Вы", answer: question.answerPartner1, isAnswered: question.answerPartner1 != nil)
                answerStatusRow(label: "Партнёр", answer: question.answerPartner2, isAnswered: question.answerPartner2 != nil)
            }
            
            if !question.isFullyAnswered {
                Button {
                    answeringAsPartner1 = question.answerPartner1 == nil
                    currentAnswer = ""
                    showingAnswerSheet = true
                } label: {
                    Text(question.answerPartner1 == nil ? "Ответить" : "Посмотреть ответы")
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
            
            if question.isFullyAnswered {
                answersRevealedSection(question)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - New Question
    private var newQuestionCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(.blue)
            
            Text("Вопрос дня ещё не задан")
                .font(.headline)
            
            Text("Сгенерируйте новый вопрос, чтобы узнать друг друга лучше")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                generateQuestion()
            } label: {
                Label("Получить вопрос", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Answer Status
    private func answerStatusRow(label: String, answer: String?, isAnswered: Bool) -> some View {
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
            
            Text("✨ Ответы раскрыты ✨")
                .font(.headline)
                .foregroundColor(.purple)
            
            answerBubble(label: "Вы", answer: question.answerPartner1 ?? "", isPartner1: true)
            answerBubble(label: "Партнёр", answer: question.answerPartner2 ?? "", isPartner1: false)
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
            
            ForEach(previousQuestions) { question in
                NavigationLink(destination: QuestionHistoryDetail(question: question)) {
                    HStack {
                        Image(systemName: question.isFullyAnswered ? "checkmark.circle.fill" : "circle.dashed")
                            .foregroundColor(question.isFullyAnswered ? .green : .orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(question.question)
                                .font(.subheadline.weight(.medium))
                                .lineLimit(1)
                            Text(question.dateAssigned, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
                
                if question != previousQuestions.last {
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
                if let question = todayQuestion {
                    Text(question.question)
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextEditor(text: $currentAnswer)
                        .frame(height: 200)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        saveAnswer()
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
                    .disabled(currentAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
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
    
    // MARK: - Helpers
    private func generateQuestion() {
        guard todayQuestion == nil else { return }
        let questionText = Self.questionPool.randomElement()!
        let question = QuestionOfTheDay(question: questionText)
        modelContext.insert(question)
        try? modelContext.save()
    }
    
    private func saveAnswer() {
        guard let question = todayQuestion else { return }
        if answeringAsPartner1 {
            question.answerPartner1 = currentAnswer
            question.partner1AnsweredAt = Date()
        } else {
            question.answerPartner2 = currentAnswer
            question.partner2AnsweredAt = Date()
        }
        try? modelContext.save()
        showingAnswerSheet = false
    }
}

// MARK: - Question History Detail
struct QuestionHistoryDetail: View {
    let question: QuestionOfTheDay
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(question.question)
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding()
                
                if question.isFullyAnswered {
                    VStack(spacing: 16) {
                        answerCard(label: "Вы", answer: question.answerPartner1 ?? "", color: .blue)
                        answerCard(label: "Партнёр", answer: question.answerPartner2 ?? "", color: .purple)
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        if question.answerPartner1 == nil {
                            statusCard("Ожидаем ответ от вас")
                        }
                        if question.answerPartner2 == nil {
                            statusCard("Ожидаем ответ от партнёра")
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("\(question.dateAssigned, style: .date)")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(colors: [.blue.opacity(0.03), .purple.opacity(0.03)],
                          startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
    
    private func answerCard(label: String, answer: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(color)
            
            Text(answer)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private func statusCard(_ text: String) -> some View {
        HStack {
            Image(systemName: "hourglass")
                .foregroundColor(.orange)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    QuestionsView()
        .modelContainer(for: [QuestionOfTheDay.self], inMemory: true)
}

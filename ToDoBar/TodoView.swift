//
//  ContentView.swift
//  ToDoBar
//
//  Created by william on 2025/4/13.
//

import SwiftUI

struct Task: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var createdAt = Date()
}

struct TodoView: View {
    @State private var tasks = [Task]()
    @State private var newTask = ""
    @State private var showingEmptyState = true
    @State private var animateNewTask = false
    
    // Environment values for theme adaptability
    @Environment(\.colorScheme) var colorScheme
    
    // Colors based on color scheme
    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "F9F9F9")
    }
    
    var cardColor: Color {
        colorScheme == .dark ? Color(hex: "2A2A2A") : Color.white
    }
    
    var accentColor: Color {
        Color(hex: "5E60CE")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Todo list")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
                
                Spacer()
                
                Menu {
                    Button(action: {
                        // Clear completed tasks
                        tasks.removeAll(where: { $0.isCompleted })
                    }) {
                        Label("Clear Completed", systemImage: "checkmark.circle")
                    }
                    
                    Button(action: {
                        // Clear all tasks
                        withAnimation {
                            tasks.removeAll()
                        }
                    }) {
                        Label("Clear All", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.horizontal)
            
            // Tasks List
            if tasks.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "checklist")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "CCCCCC"))
                        .padding(.bottom, 8)
                    
                    Text("No tasks yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add a task to get started!")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .frame(maxHeight: .infinity)
                .padding(.bottom, 20)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(tasks, id:\.id) { task in
                            TaskRow(task: binding(for: task), onDelete: { deleteTask(task) })
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            }
            
            // Add Task Area
            HStack(spacing: 10) {
                TextField("Add a new task...", text: $newTask)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(cardColor)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(animateNewTask ? accentColor : Color.clear, lineWidth: 1.5)
                    )
                    .onChange(of: newTask) { _ in
                        withAnimation(.spring()) {
                            animateNewTask = !newTask.isEmpty
                        }
                    }
                
                Button(action: addTask) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(accentColor)
                                .shadow(color: accentColor.opacity(0.4), radius: 4, x: 0, y: 2)
                        )
                }
                .disabled(newTask.isEmpty)
                .buttonStyle(PlainButtonStyle())
                .opacity(newTask.isEmpty ? 0.6 : 1.0)
                .scaleEffect(newTask.isEmpty ? 0.95 : 1.0)
                .animation(.spring(), value: newTask.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .padding(.vertical)
        .frame(width: 330, height: 450)
        .background(backgroundColor)
    }
    
    private func binding(for task: Task) -> Binding<Task> {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            fatalError("Task not found")
        }
        return $tasks[index]
    }
    
    private func addTask() {
        guard !newTask.isEmpty else { return }
        
        withAnimation(.spring()) {
            tasks.insert(Task(title: newTask), at: 0)
            newTask = ""
            animateNewTask = false
        }
    }
    
    private func deleteTask(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks.remove(at: index)
            }
        }
    }
}

// Extracted Task Row View for better organization
struct TaskRow: View {
    @Binding var task: Task
    var onDelete: () -> Void
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                withAnimation(.spring()) {
                    task.isCompleted.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(task.isCompleted ? Color(hex: "5E60CE") : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(task.isCompleted ? Color(hex: "5E60CE") : Color.gray.opacity(0.5), lineWidth: 1.5)
                        )

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            
            // Task Text
            Text(task.title)
                .font(.system(size: 16))
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted)
                .lineLimit(2)
            
            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray.opacity(0.7))
                    .font(.system(size: 18))
            }
            .buttonStyle(BorderlessButtonStyle())
            .opacity(isDragging ? 1 : 0.1)
            .scaleEffect(isDragging ? 1 : 0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(task.isCompleted ? Color(hex: "F0F0F0").opacity(0.5) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width < 0 {
                        offset = value.translation.width / 2
                        isDragging = true
                    }
                }
                .onEnded { value in
                    if value.translation.width < -75 {
                        withAnimation {
                            onDelete()
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = 0
                            isDragging = false
                        }
                    }
                }
        )
        .animation(.interactiveSpring(), value: isDragging)
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView()
    }
}

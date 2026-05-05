// noinspection SpellCheckingInspection
@file:Suppress(
    "SpellCheckingInspection",
    "GrazieInspection",
    "HardcodedText",
    "MagicNumber",
    "TooManyFunctions",
    "LongMethod",
    "OVERRIDE_DEPRECATION",
    "DEPRECATION",
)

package com.hohlitr.sipi

import android.annotation.SuppressLint
import android.app.Activity
import android.app.AlertDialog
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context.CLIPBOARD_SERVICE
import android.content.Context.MODE_PRIVATE
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import android.window.OnBackInvokedDispatcher
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID
import kotlin.math.roundToInt

private enum class Screen {
    Login,
    Collections,
    CollectionDetails,
    Quiz,
    Progress,
    Profile,
}

class MainActivity : Activity() {
    private lateinit var store: SipiStore
    private val collections get() = store.collections
    private val cards get() = store.cards
    private val groups get() = store.groups
    private val plans get() = store.plans
    private var currentUserEmail: String
        get() = store.currentUserEmail
        set(value) {
            store.currentUserEmail = value
        }

    private var quizCards = listOf<CardItem>()
    private var quizIndex = 0
    private var quizNotesVisible = true
    private var quizSelectedAnswer: String? = null
    private var currentScreen = Screen.Login
    private var currentCollectionId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        store = SipiStore(getSharedPreferences("sipi-store", MODE_PRIVATE))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT,
            ) {
                handleBack()
            }
        }
        if (store.loadData()) {
            toast("Локальные данные повреждены, загружен демо-набор")
        }
        showLogin()
    }

    @SuppressLint("GestureBackNavigation")
    @Deprecated("Handled by OnBackInvokedCallback on Android 13+")
    override fun onBackPressed() {
        handleBack()
    }

    private fun handleBack() {
        when (currentScreen) {
            Screen.Login -> finish()
            Screen.Collections -> showLogin()
            Screen.CollectionDetails -> showCollections()
            Screen.Quiz -> currentCollectionId?.let(::showCollectionDetails) ?: showCollections()
            Screen.Progress -> showCollections()
            Screen.Profile -> showCollections()
        }
    }

    private fun showLogin() {
        currentScreen = Screen.Login
        currentCollectionId = null
        val email = input("Email", currentUserEmail)
        val password = input("Пароль", "", password = true)
        val root = page("Sipi", "Тренажер памяти с элементами геймификации")
        root.addView(email)
        root.addView(password)
        root.addView(primaryButton("Войти") {
            val value = email.text.toString().trim()
            if (value.isBlank() || password.text.toString().length < 3) {
                toast("Введите email и пароль не короче 3 символов")
                return@primaryButton
            }
            currentUserEmail = value
            store.saveCurrentUserEmail()
            showCollections()
        })
        root.addView(secondaryButton("Создать демо-аккаунт") {
            currentUserEmail = email.text.toString().trim().ifBlank { "student@example.com" }
            store.saveCurrentUserEmail()
            showCollections()
        })
        setContentView(scroll(root))
    }

    private fun showCollections() {
        currentScreen = Screen.Collections
        currentCollectionId = null
        val root = page("Коллекции", "Создавайте наборы карточек и запускайте тесты по слабым темам")
        root.addView(navRow("Коллекции"))
        root.addView(primaryButton("Новая коллекция") { showCollectionDialog() })

        if (collections.isEmpty()) {
            root.addView(text("Коллекций пока нет. Создайте первую тему для изучения.", 16))
        } else {
            collections.forEach { collection ->
                val collectionCards = cardsFor(collection.id)
                val progress = collectionProgress(collection.id)
                root.addView(cardBlock {
                    addView(title(collection.title))
                    addView(text(collection.description.ifBlank { "Без описания" }, 14))
                    addView(text("${collectionCards.size} карточек · прогресс ${percent(progress)}", 14))
                    addView(progress(progress))
                    addView(horizontal {
                        addView(smallButton("Открыть") { showCollectionDetails(collection.id) })
                        addView(smallButton("Изменить") { showCollectionDialog(collection) })
                        addView(smallButton("Удалить") { confirmDeleteCollection(collection) })
                    })
                })
            }
        }

        setContentView(scroll(root))
    }

    private fun showCollectionDetails(collectionId: String) {
        currentScreen = Screen.CollectionDetails
        currentCollectionId = collectionId
        val collection = collections.firstOrNull { it.id == collectionId } ?: return showCollections()
        val root = page(collection.title, collection.description.ifBlank { "Карточки, группы, учебный план и экспорт" })

        root.addView(horizontal {
            addView(smallButton("Назад") { showCollections() })
            addView(smallButton("Тест") { startQuiz(collectionId) })
            addView(smallButton("Экспорт") { showExport(collectionId) })
        })
        root.addView(horizontal {
            addView(smallButton("Карточка") { showCardDialog(collectionId) })
            addView(smallButton("Группа") { showGroupDialog(collectionId) })
            addView(smallButton("План") { showPlanDialog(collectionId) })
        })
        root.addView(horizontal {
            addView(smallButton("Изменить") { showCollectionDialog(collection) })
            addView(smallButton("Удалить") { confirmDeleteCollection(collection) })
        })

        val collectionCards = cardsFor(collectionId)
        root.addView(section("Прогресс"))
        root.addView(progress(collectionProgress(collectionId)))
        root.addView(text("Изученность: ${percent(collectionProgress(collectionId))}", 14))

        root.addView(section("Карточки"))
        if (collectionCards.isEmpty()) {
            root.addView(text("Добавьте карточки, чтобы появился режим теста.", 14))
        }
        collectionCards.forEach { card ->
            root.addView(cardBlock {
                addView(title(card.question))
                addView(text(card.answer, 14))
                if (card.note.isNotBlank()) addView(text("Заметка: ${card.note}", 13))
                addView(text("Верно ${card.correctAnswers}/${card.attempts} · ${percent(card.mastery)}", 13))
                addView(horizontal {
                    addView(smallButton("Изменить") { showCardDialog(collectionId, card) })
                    addView(smallButton("Удалить") {
                        cards.removeAll { it.id == card.id }
                        groups.replaceAll { it.copy(cardIds = it.cardIds.filterNot { id -> id == card.id }) }
                        saveData()
                        showCollectionDetails(collectionId)
                    })
                })
            })
        }

        root.addView(section("Группы"))
        groups.filter { it.collectionId == collectionId }.forEach { group ->
            root.addView(cardBlock {
                addView(title(group.title))
                addView(text("${group.cardIds.size} карточек", 14))
                addView(smallButton("Удалить") {
                    groups.removeAll { it.id == group.id }
                    saveData()
                    showCollectionDetails(collectionId)
                })
            })
        }

        root.addView(section("Учебный план"))
        val plan = plans.firstOrNull { it.collectionId == collectionId }
        root.addView(text(plan?.let { "Цель ${percent(it.targetProgress)} до ${it.endDate}" } ?: "План пока не задан", 14))

        setContentView(scroll(root))
    }

    private fun startQuiz(collectionId: String) {
        currentCollectionId = collectionId
        quizCards = cardsFor(collectionId).sortedBy { it.mastery }.take(20)
        quizIndex = 0
        quizNotesVisible = true
        quizSelectedAnswer = null
        showQuiz(collectionId)
    }

    private fun showQuiz(collectionId: String) {
        currentScreen = Screen.Quiz
        currentCollectionId = collectionId
        if (quizCards.isEmpty()) {
            toast("В коллекции нет карточек для теста")
            return showCollectionDetails(collectionId)
        }

        val card = quizCards[quizIndex]
        val selectedAnswer = quizSelectedAnswer
        val answerOptions = answerOptionsFor(card, collectionId)
        val root = page("Тест", "Карточка ${quizIndex + 1} из ${quizCards.size}")
        root.addView(text(card.question, 22))
        root.addView(CheckBox(this).apply {
            text = "Показывать заметки"
            isChecked = quizNotesVisible
            setOnCheckedChangeListener { _, checked ->
                quizNotesVisible = checked
                showQuiz(collectionId)
            }
        })

        root.addView(section("Варианты ответа"))
        if (selectedAnswer == null) {
            answerOptions.forEach { answer ->
                root.addView(primaryButton(answer) {
                    submitQuizAnswer(collectionId, card.id, answer)
                })
            }
        } else {
            val correct = selectedAnswer == card.answer
            root.addView(text(if (correct) "Верно" else "Неверно", 20, bold = true))
            root.addView(text("Ваш ответ: $selectedAnswer", 16))
            root.addView(text("Правильный ответ: ${card.answer}", 16))
            if (quizNotesVisible && card.note.isNotBlank()) {
                root.addView(text("Заметка: ${card.note}", 14))
            }
            root.addView(primaryButton(if (quizIndex + 1 >= quizCards.size) "Завершить тест" else "Следующая карточка") {
                moveToNextQuizCard(collectionId)
            })
        }
        root.addView(secondaryButton("Завершить тест") { showCollectionDetails(collectionId) })
        setContentView(scroll(root))
    }

    private fun submitQuizAnswer(collectionId: String, cardId: String, selectedAnswer: String) {
        val index = cards.indexOfFirst { it.id == cardId }
        if (index >= 0) {
            val current = cards[index]
            val correct = selectedAnswer == current.answer
            val attempts = current.attempts + 1
            val correctAnswers = current.correctAnswers + if (correct) 1 else 0
            cards[index] = current.copy(
                attempts = attempts,
                correctAnswers = correctAnswers,
                mastery = correctAnswers.toDouble() / attempts.toDouble()
            )
            saveData()
        }
        quizSelectedAnswer = selectedAnswer
        showQuiz(collectionId)
    }

    private fun moveToNextQuizCard(collectionId: String) {
        if (quizIndex + 1 >= quizCards.size) {
            toast("Тест завершен")
            showCollectionDetails(collectionId)
        } else {
            quizIndex += 1
            quizSelectedAnswer = null
            showQuiz(collectionId)
        }
    }

    private fun answerOptionsFor(card: CardItem, collectionId: String): List<String> {
        val wrongAnswers = cardsFor(collectionId)
            .asSequence()
            .filterNot { it.id == card.id }
            .map { it.answer }
            .plus(cards.asSequence().filterNot { it.id == card.id }.map { it.answer })
            .filter { it.isNotBlank() && it != card.answer }
            .distinct()
            .take(3)
            .toMutableList()

        val fallbackAnswers = listOf(
            "Нет подходящего определения",
            "Это действие пользователя в интерфейсе",
            "Это элемент учебного плана",
            "Это показатель общего прогресса",
        )
        fallbackAnswers
            .filter { it != card.answer && it !in wrongAnswers }
            .take(3 - wrongAnswers.size)
            .forEach(wrongAnswers::add)

        return (wrongAnswers.take(3) + card.answer)
            .distinct()
            .sortedBy { "${card.id}-$it".hashCode() }
    }

    private fun showProgress() {
        currentScreen = Screen.Progress
        currentCollectionId = null
        val totalAttempts = cards.sumOf { it.attempts }
        val totalCorrect = cards.sumOf { it.correctAnswers }
        val accuracy = if (totalAttempts == 0) 0.0 else totalCorrect.toDouble() / totalAttempts
        val root = page("Прогресс", "Общая статистика обучения")
        root.addView(navRow("Прогресс"))
        root.addView(text("Точность ответов: ${percent(accuracy)}", 16))
        root.addView(progress(accuracy))
        root.addView(text("Коллекции: ${collections.size}", 14))
        root.addView(text("Карточки: ${cards.size}", 14))
        root.addView(text("Попытки: $totalAttempts", 14))
        root.addView(text("Правильные ответы: $totalCorrect", 14))
        root.addView(section("По коллекциям"))
        collections.forEach {
            root.addView(text("${it.title}: ${percent(collectionProgress(it.id))}", 14))
            root.addView(progress(collectionProgress(it.id)))
        }
        setContentView(scroll(root))
    }

    private fun showProfile() {
        currentScreen = Screen.Profile
        currentCollectionId = null
        val maxProgress = collections.maxOfOrNull { collectionProgress(it.id) } ?: 0.0
        val root = page("Профиль", currentUserEmail)
        root.addView(navRow("Профиль"))
        root.addView(section("Достижения"))
        defaultAchievements.forEach { achievement ->
            val unlocked = maxProgress >= achievement.requiredProgress
            root.addView(text("${if (unlocked) "✓" else "○"} ${achievement.title} - ${achievement.description}", 14))
        }
        root.addView(section("Учебные планы"))
        if (plans.isEmpty()) root.addView(text("Учебные планы пока не созданы.", 14))
        plans.forEach { plan ->
            val collectionTitle = collections.firstOrNull { it.id == plan.collectionId }?.title ?: plan.collectionId
            root.addView(text("$collectionTitle: цель ${percent(plan.targetProgress)} до ${plan.endDate}", 14))
        }
        root.addView(section("Экспорт"))
        root.addView(text("Экспорт коллекций выполняется из карточки коллекции и не содержит персональную статистику.", 14))
        root.addView(secondaryButton("Сбросить демо-данные") {
            confirmResetData()
        })
        root.addView(secondaryButton("Выйти") { showLogin() })
        setContentView(scroll(root))
    }

    private fun showCollectionDialog(existing: StudyCollection? = null) {
        val titleInput = input("Название", existing?.title ?: "")
        val descriptionInput = input("Описание", existing?.description ?: "")
        val form = vertical {
            addView(titleInput)
            addView(descriptionInput)
        }
        AlertDialog.Builder(this)
            .setTitle(if (existing == null) "Новая коллекция" else "Редактировать коллекцию")
            .setView(form)
            .setPositiveButton("Сохранить") { _, _ ->
                val title = titleInput.text.toString().trim()
                if (title.isBlank()) {
                    toast("Название не должно быть пустым")
                    return@setPositiveButton
                }
                if (existing == null) {
                    collections.add(
                        StudyCollection(
                            id = id(),
                            title = title,
                            description = descriptionInput.text.toString().trim(),
                            createdAt = now(),
                            updatedAt = now()
                        )
                    )
                } else {
                    val index = collections.indexOfFirst { it.id == existing.id }
                    if (index >= 0) {
                        collections[index] = existing.copy(
                            title = title,
                            description = descriptionInput.text.toString().trim(),
                            updatedAt = now(),
                        )
                    }
                }
                saveData()
                if (existing == null) {
                    showCollections()
                } else {
                    showCollectionDetails(existing.id)
                }
            }
            .setNegativeButton("Отмена", null)
            .show()
    }

    private fun showCardDialog(collectionId: String, existing: CardItem? = null) {
        val question = input("Вопрос", existing?.question ?: "")
        val answer = input("Ответ", existing?.answer ?: "")
        val note = input("Заметка", existing?.note ?: "")
        val form = vertical {
            addView(question)
            addView(answer)
            addView(note)
        }
        AlertDialog.Builder(this)
            .setTitle(if (existing == null) "Новая карточка" else "Редактировать карточку")
            .setView(form)
            .setPositiveButton("Сохранить") { _, _ ->
                if (question.text.toString().trim().isBlank() || answer.text.toString().trim().isBlank()) {
                    toast("Вопрос и ответ обязательны")
                    return@setPositiveButton
                }
                if (existing == null) {
                    cards.add(
                        CardItem(
                            id = id(),
                            collectionId = collectionId,
                            question = question.text.toString().trim(),
                            answer = answer.text.toString().trim(),
                            note = note.text.toString().trim()
                        )
                    )
                } else {
                    val index = cards.indexOfFirst { it.id == existing.id }
                    if (index >= 0) {
                        cards[index] = existing.copy(
                            question = question.text.toString().trim(),
                            answer = answer.text.toString().trim(),
                            note = note.text.toString().trim()
                        )
                    }
                }
                saveData()
                showCollectionDetails(collectionId)
            }
            .setNegativeButton("Отмена", null)
            .show()
    }

    private fun showGroupDialog(collectionId: String) {
        val collectionCards = cardsFor(collectionId)
        if (collectionCards.isEmpty()) {
            toast("Сначала добавьте карточки")
            return
        }
        val titleInput = input("Название группы", "Важные карточки")
        val checkBoxes = collectionCards.map { card ->
            CheckBox(this).apply {
                text = card.question
                textSize = 15f
            }
        }
        val form = vertical {
            addView(titleInput)
            addView(text("Выберите карточки", 14, bold = true))
            checkBoxes.forEach(::addView)
        }
        AlertDialog.Builder(this)
            .setTitle("Новая группа")
            .setView(scroll(form))
            .setPositiveButton("Создать") { _, _ ->
                val cardIds = collectionCards
                    .filterIndexed { index, _ -> checkBoxes[index].isChecked }
                    .map { it.id }
                if (cardIds.isEmpty()) {
                    toast("Выберите хотя бы одну карточку")
                    return@setPositiveButton
                }
                groups.add(
                    CardGroup(
                        id = id(),
                        collectionId = collectionId,
                        title = titleInput.text.toString().trim().ifBlank { "Группа карточек" },
                        cardIds = cardIds
                    )
                )
                saveData()
                showCollectionDetails(collectionId)
            }
            .setNegativeButton("Отмена", null)
            .show()
    }

    private fun showPlanDialog(collectionId: String) {
        val target = input("Цель изученности, %", "80")
        val days = input("Срок, дней", "14")
        val form = vertical {
            addView(target)
            addView(days)
        }
        AlertDialog.Builder(this)
            .setTitle("Учебный план")
            .setView(form)
            .setPositiveButton("Сохранить") { _, _ ->
                val targetValue = (target.text.toString().toIntOrNull() ?: 80).coerceIn(1, 100) / 100.0
                val daysValue = (days.text.toString().toIntOrNull() ?: 14).coerceIn(1, 365)
                plans.removeAll { it.collectionId == collectionId }
                plans.add(
                    StudyPlan(
                        id = id(),
                        collectionId = collectionId,
                        startDate = now(),
                        endDate = "через $daysValue дн.",
                        targetProgress = targetValue
                    )
                )
                saveData()
                showCollectionDetails(collectionId)
            }
            .setNegativeButton("Отмена", null)
            .show()
    }

    private fun showExport(collectionId: String) {
        val collection = collections.firstOrNull { it.id == collectionId } ?: return
        val json = JSONObject()
            .put("collection", JSONObject().put("title", collection.title).put("description", collection.description))
            .put(
                "cards",
                JSONArray(cardsFor(collectionId).map {
                    JSONObject().put("question", it.question).put("answer", it.answer).put("note", it.note)
                })
            )
            .put(
                "groups",
                JSONArray(groups.filter { it.collectionId == collectionId }.map {
                    JSONObject().put("title", it.title).put("cardIds", JSONArray(it.cardIds))
                })
            )
            .toString(2)

        AlertDialog.Builder(this)
            .setTitle("Экспорт без статистики")
            .setMessage(json)
            .setPositiveButton("Скопировать") { _, _ ->
                val clipboard = getSystemService(CLIPBOARD_SERVICE) as ClipboardManager
                clipboard.setPrimaryClip(ClipData.newPlainText("Sipi export", json))
                toast("Экспорт скопирован")
            }
            .setNegativeButton("Закрыть", null)
            .show()
    }

    private fun saveData() = store.saveData()

    private fun confirmDeleteCollection(collection: StudyCollection) {
        AlertDialog.Builder(this)
            .setTitle("Удалить коллекцию?")
            .setMessage("Коллекция «${collection.title}» и все ее карточки будут удалены.")
            .setPositiveButton("Удалить") { _, _ ->
                deleteCollection(collection.id)
                showCollections()
            }
            .setNegativeButton("Отмена", null)
            .show()
    }

    private fun deleteCollection(collectionId: String) {
        store.deleteCollection(collectionId)
    }

    private fun confirmResetData() {
        AlertDialog.Builder(this)
            .setTitle("Сбросить данные?")
            .setMessage("Все локальные коллекции будут заменены демо-набором.")
            .setPositiveButton("Сбросить") { _, _ ->
                resetToDemoData()
                showCollections()
            }
            .setNegativeButton("Отмена", null)
            .show()
    }

    private fun resetToDemoData() {
        store.resetToDemoData()
    }

    private fun cardsFor(collectionId: String) = cards.filter { it.collectionId == collectionId }

    private fun collectionProgress(collectionId: String): Double {
        val items = cardsFor(collectionId)
        return if (items.isEmpty()) 0.0 else items.sumOf { it.mastery } / items.size
    }

    private fun page(title: String, subtitle: String): LinearLayout = vertical {
        setPadding(dp(20), dp(18), dp(20), dp(28))
        addView(text(title, 28, bold = true))
        addView(text(subtitle, 15))
        addView(space(10))
    }

    private fun navRow(active: String): View = horizontal {
        addView(smallButton(if (active == "Коллекции") "• Коллекции" else "Коллекции") { showCollections() })
        addView(smallButton(if (active == "Прогресс") "• Прогресс" else "Прогресс") { showProgress() })
        addView(smallButton(if (active == "Профиль") "• Профиль" else "Профиль") { showProfile() })
    }

    private fun cardBlock(content: LinearLayout.() -> Unit): LinearLayout = vertical {
        setPadding(dp(14), dp(12), dp(14), dp(12))
        setBackgroundColor(Color.rgb(247, 248, 250))
        content()
        addView(space(8))
    }.also {
        it.layoutParams = LinearLayout.LayoutParams(match, wrap).apply { setMargins(0, dp(8), 0, dp(8)) }
    }

    private fun input(hint: String, value: String, password: Boolean = false): EditText =
        EditText(this).apply {
            setHint(hint)
            setText(value)
            textSize = 16f
            setSingleLine(false)
            if (password) inputType = 0x00000081
        }

    private fun title(value: String) = text(value, 18, bold = true)
    private fun section(value: String) = text(value, 20, bold = true).apply { setPadding(0, dp(18), 0, dp(4)) }

    private fun text(value: String, size: Int, bold: Boolean = false): TextView =
        TextView(this).apply {
            text = value
            textSize = size.toFloat()
            setTextColor(Color.rgb(24, 32, 48))
            if (bold) setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(0, dp(3), 0, dp(3))
        }

    private fun primaryButton(label: String, action: () -> Unit) = Button(this).apply {
        text = label
        setOnClickListener { action() }
    }

    private fun secondaryButton(label: String, action: () -> Unit) = Button(this).apply {
        text = label
        setOnClickListener { action() }
    }

    private fun smallButton(label: String, action: () -> Unit) = Button(this).apply {
        text = label
        textSize = 12f
        setOnClickListener { action() }
        layoutParams = LinearLayout.LayoutParams(0, wrap, 1f).apply { setMargins(dp(2), dp(2), dp(2), dp(2)) }
    }

    private fun progress(value: Double) = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
        max = 100
        progress = (value.coerceIn(0.0, 1.0) * 100).roundToInt()
    }

    private fun vertical(content: LinearLayout.() -> Unit = {}) = LinearLayout(this).apply {
        orientation = LinearLayout.VERTICAL
        content()
    }

    private fun horizontal(content: LinearLayout.() -> Unit = {}) = LinearLayout(this).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        content()
    }

    private fun scroll(view: View) = ScrollView(this).apply { addView(view) }
    private fun space(height: Int) = View(this).apply { layoutParams = LinearLayout.LayoutParams(match, dp(height)) }
    private fun dp(value: Int) = (value * resources.displayMetrics.density).roundToInt()
    private fun id() = UUID.randomUUID().toString()
    private fun now() = System.currentTimeMillis().toString()
    private fun percent(value: Double) = "${(value.coerceIn(0.0, 1.0) * 100).roundToInt()}%"
    private fun toast(value: String) = Toast.makeText(this, value, Toast.LENGTH_SHORT).show()

    private val match = LinearLayout.LayoutParams.MATCH_PARENT
    private val wrap = LinearLayout.LayoutParams.WRAP_CONTENT
}

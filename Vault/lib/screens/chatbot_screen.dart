import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/vault_navbar.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with SingleTickerProviderStateMixin {

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isTyping = false;

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  final Map<String, Map<String, String>> _responses = {
    // Casual greetings
    'hello': {'casual': 'Hey there! 👋 How\'s your day going?', 'professional': 'Hello. How may I assist you with your finances today?'},
    'hi': {'casual': 'Hi! Great to see you! What\'s up?', 'professional': 'Greetings. I\'m ready to help with your financial questions.'},
    'hey': {'casual': 'Hey hey! Ready to chat about money?', 'professional': 'Good day. How can I be of service?'},
    'how are you': {'casual': 'I\'m doing awesome! Thanks for asking. Just here crunching numbers and helping people like you!', 'professional': 'I\'m functioning optimally. Ready to provide financial assistance.'},
    'whats up': {'casual': 'Not much, just thinking about compound interest and how it can make you rich! What about you?', 'professional': 'I\'m processing financial data. What would you like to discuss?'},
    'good morning': {'casual': 'Morning! ☀️ Hope you\'re ready to tackle your financial goals today!', 'professional': 'Good morning. I hope you\'re starting your day with financial clarity.'},
    'good afternoon': {'casual': 'Afternoon! Half the day gone, but plenty of time to make smart money moves!', 'professional': 'Good afternoon. I\'m available for any financial consultations.'},
    'good evening': {'casual': 'Evening! 🌙 Perfect time to review today\'s spending and plan for tomorrow.', 'professional': 'Good evening. A good time to reflect on your financial decisions.'},
    'thanks': {'casual': 'You\'re welcome! Happy to help my favorite human! 😊', 'professional': 'You\'re welcome. I\'m here whenever you need assistance.'},
    'thank you': {'casual': 'Anytime! That\'s what I\'m here for!', 'professional': 'My pleasure. Financial health is a continuous journey.'},

    // Budgeting
    'budget': {'casual': 'Budgets are like diets for your wallet - nobody likes them but they work! Want me to help you set one up?', 'professional': 'Budgeting is the cornerstone of financial management. I can help you create a comprehensive budget based on your income and expenses.'},
    'how to budget': {'casual': 'Start by tracking what you spend (yes, including those sneaky coffee runs!). Then use the 50/30/20 rule - 50% needs, 30% wants, 20% savings. Easy peasy!', 'professional': 'I recommend the zero-based budgeting method where every dollar has a purpose. Track your income, categorize expenses, and allocate funds accordingly.'},
    'budgeting tips': {'casual': 'Pay yourself first! Save before you spend. Also, try the envelope method for variable expenses - it\'s old school but it works!', 'professional': 'Consider implementing the 50/30/20 rule: 50% for necessities, 30% for discretionary spending, and 20% for financial goals and debt reduction.'},
    'monthly budget': {'casual': 'Your monthly budget should be like a roadmap for your money. Without it, you might end up in places you didn\'t plan to go!', 'professional': 'A monthly budget should align with your financial goals and cash flow. Would you like me to help you create a template?'},

    // Saving
    'save': {'casual': 'Saving money is like planting a tree - best time was yesterday, second best time is today! What are you saving for?', 'professional': 'Saving is essential for financial security. I recommend automating your savings to build consistency.'},
    'saving tips': {'casual': 'Try the "24-hour rule" for non-essential purchases - wait a day and see if you still want it. You\'d be surprised how many things you don\'t actually need!', 'professional': 'Maximize savings by reviewing subscriptions, negotiating bills, and using high-yield savings accounts for better interest rates.'},
    'emergency fund': {'casual': 'Your emergency fund is your financial safety net - it catches you when life throws curveballs. Aim for 3-6 months of expenses.', 'professional': 'An emergency fund should cover 3-6 months of essential expenses and be kept in a liquid, accessible account.'},
    'how much to save': {'casual': 'Try to save at least 20% of your income. But hey, even 5% is better than nothing! Start small and build up.', 'professional': 'Financial experts recommend saving 15-20% of your gross income for long-term goals and retirement.'},
    'save for vacation': {'casual': 'Ooh, vacation! Where are we going? 😄 Set up a separate savings account and automate transfers. Future you on the beach will thank present you!', 'professional': 'Calculate your target vacation budget and timeline, then determine monthly savings needed. Consider using a dedicated high-yield savings account.'},
    'save for house': {'casual': 'Dreaming of your own place? Awesome! Start with a separate savings account and look into first-time home buyer programs. Every rupee counts!', 'professional': 'For a down payment, aim for 20% to avoid PMI. Research first-time home buyer programs and consider reducing your timeline with additional income streams.'},

    // Investing
    'invest': {'casual': 'Investing is how money makes money while you sleep! Start with index funds - they\'re like the "set it and forget it" of investing.', 'professional': 'Investing involves allocating resources with expected returns. Consider your risk tolerance, time horizon, and diversification strategy.'},
    'investment basics': {'casual': 'Think of investing like growing a garden. You plant seeds (money), water them (add more), and over time they grow into something much bigger!', 'professional': 'Key investment principles include diversification, compound interest, risk management, and asset allocation aligned with your goals.'},
    'stocks': {'casual': 'Stocks are like owning a tiny piece of a company. When they do well, you do well! But remember, what goes up can also come down.', 'professional': 'Stocks represent equity ownership. Consider fundamental analysis, market trends, and your risk tolerance before investing.'},
    'mutual funds': {'casual': 'Mutual funds are like a basket of investments - you buy one and get pieces of lots of different companies. Instant diversification!', 'professional': 'Mutual funds pool money from multiple investors to invest in diversified portfolios. Evaluate expense ratios and historical performance.'},
    'index funds': {'casual': 'Index funds are the chill, low-maintenance cousin of investing. They just follow the market and usually outperform actively managed funds over time.', 'professional': 'Index funds track market indices with lower fees and generally provide market-matching returns, making them ideal for passive investors.'},
    'sip': {'casual': 'SIP is like a gym membership for your money - small, regular investments that build wealth over time. No need to time the market!', 'professional': 'Systematic Investment Plans allow regular, disciplined investing with rupee cost averaging benefits and power of compounding.'},

    // Debt management
    'debt': {'casual': 'Debt can feel like carrying a heavy backpack everywhere. Let\'s lighten that load! Two popular ways: snowball (smallest first) or avalanche (highest interest first).', 'professional': 'Debt management strategies include the avalanche method (highest interest first) or snowball method (smallest balance first) for psychological wins.'},
    'credit card debt': {'casual': 'Credit card debt is like the friend who eats your food and never pays back. Try to pay more than the minimum - those interest charges add up fast!', 'professional': 'Focus on paying down high-interest credit card debt first. Consider balance transfers or consolidation loans for better rates.'},
    'loan repayment': {'casual': 'Paying off loans feels amazing! Even small extra payments can shave months off your loan term. Every little bit helps!', 'professional': 'Accelerate loan repayment by making biweekly payments or rounding up payments. Ensure no prepayment penalties exist.'},
    'credit score': {'casual': 'Your credit score is like a report card for grown-ups. Pay bills on time and keep credit utilization under 30% to keep it healthy!', 'professional': 'Credit scores range from 300-850 based on payment history, utilization, length of history, credit mix, and new inquiries.'},
    'improve credit': {'casual': 'Want better credit? Pay on time, keep balances low, and don\'t close old cards - they\'re like your credit history trophies!', 'professional': 'Improve credit by maintaining on-time payments, keeping utilization below 30%, and limiting new credit applications.'},

    // Financial planning
    'financial goals': {'casual': 'Goals give your money purpose! Whether it\'s a new phone or early retirement, write them down and make a plan. I can help!', 'professional': 'Set SMART financial goals: Specific, Measurable, Achievable, Relevant, and Time-bound. Prioritize them based on urgency and importance.'},
    'retirement': {'casual': 'Retirement might seem far away, but compound interest loves time! The earlier you start, the less you need to save each month. Magic!', 'professional': 'Retirement planning should account for your desired lifestyle, inflation, healthcare costs, and potential longevity. Start early to leverage compounding.'},
    'financial independence': {'casual': 'Financial independence means your money works harder than you do! It\'s about having options and freedom. Want to chat about the FIRE movement?', 'professional': 'Financial independence requires calculating your FIRE number: 25x your annual expenses. This allows a 4% safe withdrawal rate.'},
    'tax planning': {'casual': 'Taxes - nobody likes paying them, but we all love roads and schools! Smart planning can keep more money in your pocket legally.', 'professional': 'Tax planning involves understanding deductions, credits, and tax-advantaged accounts like 401(k)s and IRAs to minimize liability.'},
    'estate planning': {'casual': 'Estate planning isn\'t just for the rich - it\'s for anyone who wants to decide what happens to their stuff. Plus, it saves your loved ones headaches later.', 'professional': 'Estate planning includes wills, trusts, power of attorney, and healthcare directives to ensure your assets transfer according to your wishes.'},

    // Insurance
    'insurance': {'casual': 'Insurance is like an umbrella - you hope you never need it, but you\'re glad to have it when it rains!', 'professional': 'Insurance protects against financial loss. Key types include health, life, disability, auto, and homeowner\'s/renter\'s insurance.'},
    'life insurance': {'casual': 'Life insurance is about protecting the people who depend on you. Term life is usually the simplest and most affordable option.', 'professional': 'Term life insurance provides coverage for a specific period, while whole life includes a cash value component. Choose based on your needs.'},
    'health insurance': {'casual': 'Health insurance is complicated but important - one hospital visit without it could wipe out years of savings!', 'professional': 'Health insurance options include employer plans, marketplace plans, and high-deductible plans with HSAs. Compare premiums, deductibles, and networks.'},

    // Education
    'financial literacy': {'casual': 'Financial literacy is like learning a new language - the language of money! Start with budgeting, then move to investing. You\'ll be fluent in no time!', 'professional': 'Financial literacy encompasses budgeting, saving, investing, debt management, and understanding financial products and risks.'},
    'learn about money': {'casual': 'Learning about money can actually be fun! I recommend books like "Rich Dad Poor Dad" and following finance YouTubers who make it entertaining.', 'professional': 'Recommended resources include financial literacy courses, reputable books, and following certified financial planners for professional insights.'},
    'books': {'casual': 'Love reading about money? "The Psychology of Money" is awesome, and "I Will Teach You to Be Rich" is practical and funny!', 'professional': 'Essential reading includes "The Intelligent Investor," "Rich Dad Poor Dad," and "The Millionaire Next Door" for foundational knowledge.'},

    // Default responses
    'default_casual': 'Hmm, I\'m not sure about that! But I love chatting about money stuff. Ask me about budgeting, saving, investing, or debt - I\'m your penny for those thoughts! 😊',
    'default_professional': 'I don\'t have information on that specific topic. However, I can assist with financial matters including budgeting, saving, investing, debt management, and financial planning. How may I help?',

    // Small talk
    'weather': {'casual': 'I don\'t go outside (I\'m a digital penny!), but I hope it\'s nice weather for you to work on your financial goals!', 'professional': 'I\'m designed to assist with financial matters rather than weather forecasts.'},
    'joke': {'casual': 'Why did the penny break up with the dollar? It wasn\'t making enough cents! 😄 Want another?', 'professional': 'I\'m optimized for financial assistance rather than entertainment, but I appreciate your interest in lightening the mood!'},
    'fun fact': {'casual': 'Fun fact: A penny costs more than 1 rupee to make! Crazy, right? That\'s why we\'re all about digital money here at Vault!', 'professional': 'Interesting fact: The concept of compound interest dates back to ancient civilizations, demonstrating the long-standing importance of financial growth.'},
  };

  @override
  void initState() {
    super.initState();

    _messages.add(ChatMessage(
      text: 'Hi! I\'m Penny, your AI financial assistant. Ask me anything about money, or just chat with me! I can do both casual and professional conversations.',
      isUser: false,
      timestamp: DateTime.now(),
    ));

    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _typingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _typingAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUser: true,
        timestamp: DateTime.now(),
      ));

      _isTyping = true;
    });

    String userMessage = _messageController.text.toLowerCase().trim();
    _messageController.clear();

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      _generateResponse(userMessage);
    });
  }

  void _generateResponse(String userMessage) {
    String response = '';

    // Determine if user wants casual or professional tone
    bool wantsCasual = true; // Default to casual

    // Check for keywords that indicate preference for professional tone
    List<String> professionalIndicators = ['professional', 'formal', 'serious', 'advice', 'expert', 'technical'];
    for (var indicator in professionalIndicators) {
      if (userMessage.contains(indicator)) {
        wantsCasual = false;
        break;
      }
    }

    // Also check if user explicitly asks for casual
    if (userMessage.contains('casual') || userMessage.contains('friendly') || userMessage.contains('chill')) {
      wantsCasual = true;
    }

    String normalized = userMessage.replaceAll(RegExp(r'[^a-zA-Z ]'), '').trim();

    // Check for exact matches first (for multi-word phrases)
    List<String> exactPhrases = [
      'how are you', 'good morning', 'good afternoon', 'good evening',
      'thank you', 'credit card debt', 'emergency fund', 'mutual funds',
      'index funds', 'credit score', 'life insurance', 'health insurance',
      'estate planning', 'financial goals', 'financial independence',
      'tax planning', 'financial literacy', 'learn about money',
      'how to budget', 'budgeting tips', 'monthly budget', 'saving tips',
      'how much to save', 'save for vacation', 'save for house',
      'investment basics', 'fun fact', 'loan repayment', 'improve credit'
    ];

    bool foundExact = false;
    for (var phrase in exactPhrases) {
      if (normalized.contains(phrase)) {
        String key = phrase.replaceAll(' ', '_');
        if (_responses.containsKey(phrase)) {
          response = wantsCasual
              ? _responses[phrase]!['casual']!
              : _responses[phrase]!['professional']!;
          foundExact = true;
        } else if (_responses.containsKey(key)) {
          response = wantsCasual
              ? _responses[key]!['casual']!
              : _responses[key]!['professional']!;
          foundExact = true;
        }
        break;
      }
    }

    // If no exact phrase match, check individual words
    if (!foundExact) {
      List<String> words = normalized.split(' ');

      for (var word in words) {
        if (word.isEmpty) continue;

        // Check for word in responses
        for (var key in _responses.keys) {
          if (word == key || (key.contains(word) && word.length > 3)) {
            if (_responses[key]!.containsKey('casual') && _responses[key]!.containsKey('professional')) {
              response = wantsCasual
                  ? _responses[key]!['casual']!
                  : _responses[key]!['professional']!;
              foundExact = true;
              break;
            }
          }
        }
        if (foundExact) break;
      }
    }

    // If still no match, use default based on tone
    if (response.isEmpty) {
      response = wantsCasual ? _responses['default_casual']! : _responses['default_professional']!;
    }

    setState(() {
      _isTyping = false;

      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _suggestQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: 'Chat cleared! I\'m still here if you need me. Ask me anything about money or just chat!',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2A30),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Penny",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),

      body: Column(
        children: [
          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2A30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '💬 Try: "Give me professional advice" or "Let\'s chat casually"',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Quick suggestions
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSuggestionChip("How to budget"),
                _buildSuggestionChip("Saving tips"),
                _buildSuggestionChip("Investment basics"),
                _buildSuggestionChip("Credit score"),
                _buildSuggestionChip("Emergency fund"),
                _buildSuggestionChip("Give professional advice"),
                _buildSuggestionChip("Tell me a joke"),
                _buildSuggestionChip("Fun fact"),
              ],
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1F2A30),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Ask Penny anything...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFF14B8A6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: const VaultNavbar(
        selectedIndex: 4,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF14B8A6).withOpacity(0.2),
                child: const Text('💰', style: TextStyle(fontSize: 16)),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF14B8A6).withOpacity(0.2)
                    : const Color(0xFF1F2A30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16, left: 40),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF14B8A6),
            child: Text('💰', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(width: 8),
          Text(
            "Penny is typing...",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () => _suggestQuestion(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2A30),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF14B8A6).withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
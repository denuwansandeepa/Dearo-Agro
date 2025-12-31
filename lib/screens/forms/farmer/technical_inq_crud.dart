import 'package:farmeragriapp/api/technical_inquiry_api.dart';
import 'package:farmeragriapp/models/technical_inquiry_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class TechnicalInquiryList extends StatefulWidget {
  final String baseUrl;

  const TechnicalInquiryList({super.key, required this.baseUrl});

  @override
  _TechnicalInquiryListState createState() => _TechnicalInquiryListState();
}

class _TechnicalInquiryListState extends State<TechnicalInquiryList> {
  late TechnicalInquiryApi _tapi;
  List<TechnicalInquiry> _inquiries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tapi = TechnicalInquiryApi(widget.baseUrl);
    _loadInquiries();
  }

  Future<void> _loadInquiries() async {
    setState(() => _isLoading = true);
    try {
      final inquiries = await _tapi.getInquiries();
      setState(() => _inquiries = inquiries);
    } catch (e) {
      _showSnackBar('Error loading inquiries: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteInquiry(String id) async {
    setState(() => _isLoading = true);
    try {
      await _tapi.deleteInquiry(id);
      _showSnackBar('Inquiry deleted successfully');
      _loadInquiries();
    } catch (e) {
      _showSnackBar('Failed to delete inquiry', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToEditScreen(TechnicalInquiry inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInquiryScreen(
          inquiry: inquiry,
          api: _tapi,
          onUpdate: _loadInquiries,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: isWide ? 200 : 150,
                flexibleSpace: Stack(
                  children: [
                    ClipPath(
                      clipper: ArcClipper(),
                      child: Container(
                        height: isWide ? 250 : 190,
                        color: const Color.fromRGBO(87, 164, 91, 0.8),
                      ),
                    ),
                   
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'My Inquiries',
                          style: GoogleFonts.poppins(
                            fontSize: isWide ? 24 : 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _isLoading && _inquiries.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadInquiries,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildInquiryList(),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInquiryList() {
    if (_inquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No inquiries found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _inquiries.length,
      itemBuilder: (context, index) => _buildInquiryCard(_inquiries[index]),
    );
  }

  Widget _buildInquiryCard(TechnicalInquiry inquiry) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditScreen(inquiry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      inquiry.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit,
                                color: Color.fromRGBO(87, 164, 91, 0.8)),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                        onTap: () => _navigateToEditScreen(inquiry),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                        onTap: () => _deleteInquiry(inquiry.id),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                inquiry.description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    backgroundColor: Colors.grey[200],
                    label: Text(
                      'Date: ${inquiry.date.substring(0, 10)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  if (inquiry.status != null)
                    Chip(
                      backgroundColor: _getStatusColor(inquiry.status!),
                      label: Text(
                        inquiry.status!.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class EditInquiryScreen extends StatefulWidget {
  final TechnicalInquiry inquiry;
  final TechnicalInquiryApi api;
  final VoidCallback onUpdate;

  const EditInquiryScreen({
    super.key,
    required this.inquiry,
    required this.api,
    required this.onUpdate,
  });

  @override
  _EditInquiryScreenState createState() => _EditInquiryScreenState();
}

class _EditInquiryScreenState extends State<EditInquiryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.inquiry.title);
    _descriptionController =
        TextEditingController(text: widget.inquiry.description);
  }

  Future<void> _updateInquiry() async {
    setState(() => _isLoading = true);
    try {
      final updatedInquiry = TechnicalInquiry(
        id: widget.inquiry.id,
        title: _titleController.text,
        description: _descriptionController.text,
        date: widget.inquiry.date,
        status: widget.inquiry.status,
        imagePath: widget.inquiry.imagePath,
        documentPath: widget.inquiry.documentPath,
      );

      await widget.api.updateInquiry(updatedInquiry);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inquiry updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onUpdate();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTextField(_titleController, "Title"),
                        const SizedBox(height: 16),
                        _buildTextField(_descriptionController, "Description",
                            maxLines: 5),
                        const SizedBox(height: 24),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 150,
      flexibleSpace: Stack(
        children: [
          ClipPath(
            clipper: ArcClipper(),
            child: Container(
              height: 190,
              color: const Color.fromRGBO(87, 164, 91, 0.8),
            ),
          ),
          Positioned(
            top: 30,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Edit Inquiry',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _isLoading ? null : _updateInquiry,
            ),
          ),
        ],
      ),
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _updateInquiry,
        child: Text(
          'Save Changes',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

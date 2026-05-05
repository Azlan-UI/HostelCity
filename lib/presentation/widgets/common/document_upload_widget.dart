import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/enums/verification_enums.dart';


class DocumentUploadWidget extends StatefulWidget {
  final String label;
  final String? imageUrl;
  final VoidCallback? onUpload;
  final VoidCallback? onDelete;
  final bool isLoading;
  final String? helpText;
  final IconData icon;
  final Function(XFile?)? onFileSelected;
  final String? initialImageUrl;
  final VerificationStatus? verificationStatus;
  final String? rejectionReason;

  const DocumentUploadWidget({
    super.key,
    required this.label,
    this.imageUrl,
    this.onUpload,
    this.onDelete,
    this.isLoading = false,
    this.helpText,
    this.icon = Icons.upload_file,
    this.onFileSelected,
    this.initialImageUrl,
    this.verificationStatus,
    this.rejectionReason,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  XFile? _localFile;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _localFile = image;
      });
      if (widget.onFileSelected != null) {
        widget.onFileSelected!(image);
      }
      if (widget.onUpload != null) {
        widget.onUpload!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFile = _localFile != null || 
                         (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) || 
                         (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        if (widget.helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helpText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
        const SizedBox(height: 12),
        if (hasFile)
          _buildUploadedDocument(context)
        else
          _buildUploadButton(context),
      ],
    );
  }

  Widget _buildUploadedDocument(BuildContext context) {
    bool isRejected = widget.verificationStatus == VerificationStatus.rejected;
    bool isPending = widget.verificationStatus == VerificationStatus.pending;
    
    Color sectionColor = AppColors.success;
    IconData sectionIcon = Icons.check_circle;
    String statusText = _localFile != null ? 'File Selected' : 'Document Uploaded';
    
    if (isRejected) {
      sectionColor = AppColors.error;
      sectionIcon = Icons.error;
      statusText = 'Document Rejected';
    } else if (isPending && _localFile == null) {
      sectionColor = AppColors.warning;
      sectionIcon = Icons.pending;
      statusText = 'Verification Pending';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sectionColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sectionColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sectionIcon, color: sectionColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: sectionColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _localFile != null ? _localFile!.name : 
                        (isRejected ? 'Please upload a new document' : 'Tap to change'),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isRejected ? Icons.upload : Icons.edit),
                onPressed: _pickFile,
                color: AppColors.primary,
                tooltip: isRejected ? 'Re-upload Document' : 'Change Document',
              ),
              if (widget.onDelete != null || _localFile != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _localFile = null;
                    });
                    if (widget.onFileSelected != null) {
                      widget.onFileSelected!(null);
                    }
                    if (widget.onDelete != null) {
                      widget.onDelete!();
                    }
                  },
                  color: AppColors.error,
                ),
            ],
          ),
          if (isRejected && widget.rejectionReason != null && _localFile == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.rejectionReason!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return InkWell(
      onTap: widget.isLoading ? null : _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: widget.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Icon(
                    widget.icon,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to upload ${widget.label}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG, or PDF (Max 5MB)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

class MultiDocumentUploadWidget extends StatelessWidget {
  final String label;
  final List<XFile> documents;
  final VoidCallback onAddDocument;
  final Function(int index) onDeleteDocument;
  final bool isLoading;
  final String? helpText;
  final int maxDocuments;

  const MultiDocumentUploadWidget({
    super.key,
    required this.label,
    required this.documents,
    required this.onAddDocument,
    required this.onDeleteDocument,
    this.isLoading = false,
    this.helpText,
    this.maxDocuments = 5,
  });

  @override
  Widget build(BuildContext context) {
    final canAddMore = documents.length < maxDocuments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Spacer(),
            Text(
              '${documents.length}/$maxDocuments',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            helpText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
        const SizedBox(height: 12),

        // Display selected documents
        if (documents.isNotEmpty)
          ...documents.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document ${index + 1}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            file.name,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => onDeleteDocument(index),
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

        // Add more button
        if (canAddMore)
          InkWell(
            onTap: isLoading ? null : onAddDocument,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          documents.isEmpty ? 'Upload $label' : 'Add Another Document',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );
  }
}